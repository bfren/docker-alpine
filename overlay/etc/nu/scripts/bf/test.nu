use dump.nu
use fs.nu
use write.nu

# Execute tests with debug switch enabled
# Inspired by https://github.com/nushell/nupm/blob/main/nupm/test.nu to work in this ecosystem
export def main [
    --path: string  # dir(s) to include with default PATH - MUST end with a colon ':'
] {
    let e = {
        BF_DEBUG: "1"
        PATH: $"($path)/usr/bin/bf:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    }
    with-env $e { discover | execute }
}

# Discover tests to execute
def discover [] {
    # ensure tests directory contains a mod.nu file
    if ("/etc/nu/scripts/tests/mod.nu" | fs is_not_file) {
        write error "The tests directory does not exist, or does not contain a mod.nu file."
    }

    # get list of tests
    let tests = ^nu ...[
        --commands
        'use tests

        scope commands
        | where ($it.name | str starts-with tests)
        | get name
        | str replace "tests" ""
        | str trim
        | to nuon
        '
    ] | from nuon

    # if no tests are found, exit
    if ($tests | length) == 0 {
        write "No tests found."
        exit
    }

    # execute each test
    write $"Found ($tests | length) tests."

    # return
    $tests
}

# Execute each discovered test in parallel
# WARNING: this means tests need to be self-contained as the execution order cannot be guaranteed
def execute []: list<string> -> any {
    let results = $in | sort | par-each {|x|
        # capture result
        let result = do { ^nu -c $"use tests * ; ($x)" } | complete

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
        write ok $"Executed all ($results | length) tests successfully."
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
