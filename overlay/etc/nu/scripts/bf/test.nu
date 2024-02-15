use dump.nu
use write.nu

# Run test suite if tests exist
# Inspired by https://github.com/nushell/nupm/blob/main/nupm/test.nu to work in this ecosystem
export def main [] {
    # ensure tests directory contains a mod.nu file
    let scripts_dir = "/etc/nu/scripts"
    if ($scripts_dir | path join "tests/mod.nu" | path type) != "file" {
        write notok "The tests directory does not contain a mod.nu file."
        exit
    }

    # get list of tests
    cd $scripts_dir
    let tests = ^nu ...[
        --no-config-file
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

    # execute each test
    write $"Found ($tests | length) tests."
    let results = $tests | par-each {|x|
        # capture result
        let result = do { ^nu -c $"use tests * ; ($x)" } | complete

        # output result on success
        if $result.exit_code == 0 { $"Test ($x) (ansi gb)OK(ansi reset)" | print }

        # store result
        {
            test: $x
            stdout: $result.stdout
            stderr: $result.stderr
            exit_code: $result.exit_code
        }
    }

    # get successes and failures
    let successes_length = $results | where exit_code == 0 | length
    let failures = $results | where exit_code != 0
    $failures | each {|x|
        $"(char newline)(ansi rb)Test ($x.test) failed.(ansi reset)(char newline)($x.stderr)" | print
    }

    # show result message
    write $"Ran ($results | length) tests. ($successes_length) succeeded, ($failures | length) failed."

    # on failure, ensure error code exit
    if ($failures | length) > 0 { write error "Some tests failed." }
}
