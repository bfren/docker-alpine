use dump.nu
use write.nu

# Handle an operation using `complete`, returning the operation stdout or printing stderr
#
# ```nu
# > { ^external } | bf handle
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is 0, stdout will be trimmed and returned
#   - if the exit code is not 0, a nu error containing stderr will be returned
#
# ```nu
# > { ^external } | bf handle --code-only
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - the exit code will be returned
#   - **this option overrides all others**
#
# ```nu
# > { ^external } | bf handle --ignore-success
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if exit code is 0, stdout will be discarded - it is the equivalent of `--on-success {|out| $out | ignore }`
#   - **this option overrides `--dump-result` and `--on-success`**
#
# ```nu
# > { ^external } | bf handle --ignore-error
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - whatever the exit code is, stdout will be trimmed and returned
#   - **this option overrides `--dump-result` and `--on-failure`**
#
# ```nu
# > { ^external } | bf handle --dump-result "Some Operation"
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is not 0, and BF_DEBUG is 1, the entire $result object will be dumped with 'Some Operation' used as a heading
#   - a nu error containing stderr will be returned
#
# ```nu
# > { ^external } | bf handle --on-failure {|code, err| $"($err): ($code)" | print }
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is 0, stdout will be trimmed and returned
#   - if the exit code is not 0, $on_failure will be run - in this case the stderr and exit code will be printed
#
# ```nu
# > { ^external } | bf handle --on-success {|out| $out | print }
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is 0, $on_success will be run - in this case stdout will be printed
#   - if the exit code is not 0, a nu error containing stderr will be returned
export def main [
    script?: string             # The name of the calling script or executable
    --code-only (-c)            # If set, only the exit code will be returned - overrides all other options
    --debug (-D)                # If set, the result object will be dumped immediately before any processing
    --dump-result (-d): string  # On error, dump the full $result object with this text
    --ignore-error (-i)         # If set, any errors will be ignored and $result.stdout will be returned
    --ignore-success (-I)       # If set, a successful $result will be discarded
    --on-failure (-f): closure  # On failure, optionally run this closure with $code and $stderr as inputs
    --on-success (-s): closure  # On success, optionally run this closure with $stdout as input
]: closure -> any {
    # capture input so it can be reused
    let result = do $in | complete

    # if debugging is enabled, dump the $result object (it won't show unless BF_DEBUG is 1)
    if $debug { $result | dump }

    # return exit code
    if $code_only { return $result.exit_code }

    # if ignoring success, return nothing - otherwise, run closure (if it has been set) and return
    if $result.exit_code == 0 {
        if $ignore_success { return }
        if ($on_success | is-not-empty) { do $on_success $result.stdout } else { $result.stdout | str trim } | return $in
    }

    # if ignoring errors, return the $result.stdout string
    if $ignore_error { $result.stdout | str trim | return $in }

    # if we get here, the operation failed
    # if $dump_result flag is set, dump the $result object (it won't show unless BF_DEBUG is 1)
    if ($dump_result | is-not-empty) { $result | dump -t $dump_result }

    # run $on_failure closure (if it has been set) and return
    if ($on_failure | is-not-empty) { do $on_failure $result.exit_code $result.stderr | return $in }

    # write exit code and stderr
    write error $"($result.exit_code): ($result.stderr | str trim)" $"($script)"
}
