use build.nu
use dump.nu
use fs.nu
use write.nu

# Execute tests with debug switch enabled
# Inspired by https://github.com/nushell/nupm/blob/main/nupm/test.nu to work in this ecosystem
export def main [
    --ignore-http (-H)  # if set will ignore HTTP tests (for speed)
    --path: string      # dir(s) to include with default PATH - *must* end with :
] {
    let e = {
        PATH: $"($path)/usr/bin/bf:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    }
    with-env $e { discover --ignore-http=($ignore_http) | execute }
}

# Discover tests to execute
def discover [
    --ignore-http (-H)  # if set will ignore HTTP tests (for speed)
] {
    # ensure tests directory contains a mod.nu file
    if ("/etc/nu/scripts/tests/mod.nu" | fs is_not_file) {
        write error "The tests directory does not exist, or does not contain a mod.nu file." test/discover
    }

    # get list of tests
    let tests = ^$nu.current-exe ...[
        --no-config-file
        --commands
        "use tests

        scope commands
            | where ($it.name | str starts-with tests)
            | get name
            | str replace "tests" ""
            | str trim
            | to nuon
        "
    ] | from nuon

    # if no tests are found, exit
    if ($tests | length) == 0 {
        write "No tests found." test/discover
        exit
    }

    # remove http tests
    if $ignore_http {
        let tests_without_http = $tests | where not ($it | str starts-with "http")
        return $tests_without_http
    } else {
        return $tests
    }
}

# Execute each discovered test in parallel
# WARNING: this means tests need to be self-contained as the execution order cannot be guaranteed
def execute []: list<string> -> any {
    with-env {BF_ETC: "/etc/bf"} { build show }
    write $"Executing ($in | length) tests." test/execute

    # define environment variables
    let e = {
        BF_DEBUG: "1"
        BF_TESTING: "1"
    }

    # make sure tests are really being executed before trusting any results
    with-env $e { check_canary }

    # run tests in parallel
    let results = $in | par-each {|x|
        # capture result
        let result = with-env $e { run_test $x }

        # output result on success
        if $result.exit_code == 0 { $"(ansi gb)OK(ansi reset) ($x)" | print }

        # return result
        {
            test: $x
            stdout: $result.stdout
            stderr: $result.stderr
            exit_code: $result.exit_code
        }
    }

    # if no failures, print success message
    let failures = $results | where exit_code != 0
    if ($failures | length) == 0 {
        write ok $"Executed all ($results | length) tests successfully." test/execute
        return
    }

    # output each failure and error message
    $failures | each {|x|
        $"(char newline)(ansi rb)FAILED(ansi reset) ($x.test)" | print
        $"(char newline)#== stderr ==#(char newline)($x.stderr)" | print
        $"(char newline)#== stdout ==#(char newline)($x.stdout)" | print
        char newline | print
    }
    error make --unspanned {msg: $"($failures | length) of ($results | length) tests failed."}
}

# Run a test in a new Nushell process, with the tests module loaded - returns the output of complete
def run_test [
    test: string    # The test to run (or any Nushell command)
]: nothing -> record {
    ^$nu.current-exe --no-config-file --commands $"use tests * ; ($test)" | complete
}

# Make sure the runner really executes tests: a canary that must fail is run in exactly the same way as a test -
# if it exits with 0, or fails without its marker (e.g. the tests module did not load), no result can be trusted
def check_canary []: nothing -> nothing {
    let marker = "bf-test-canary"
    let result = run_test $"error make --unspanned {msg: '($marker)'}"

    if $result.exit_code == 0 or not ($result.stderr | str contains $marker) {
        $"(char newline)#== canary stderr ==#(char newline)($result.stderr)" | print
        write error "The test runner is not executing tests correctly, so results cannot be trusted." test/check_canary
    }

    write debug "Canary failed as expected - tests are being executed." test/check_canary
}
