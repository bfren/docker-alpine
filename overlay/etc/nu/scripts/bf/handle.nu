use dump.nu

# Handle an operation using `complete`, returning the operation result or printing an error message
#
# With no flags:
#   - on success the value of `stdout` is returned
#   - on error the exit code and `stderr` are used to write to the console
# The flags allow you to dump the full $result object or override what happens on success or error
export def main [
    script?: string             # The name of the calling script or executable
    --dump-result (-d): string  # On error, dump the full $result object with this text
    --code-only (-c)            # If set, only the exit code will be returned - overrides all other options
    --ignore-errors (-i)        # If set, any errors will be ignored and $result.stdout will be returned whatever it is
    --on-failure (-f): closure  # On failure, optionally run this closure with $code and $stderr as inputs
    --on-success (-s): closure  # On success, optionally run this closure with $stdout as input
] {
    # capture input so it can be reused
    let result = do $in | complete

    # return exit code
    if $code_only { return $result.exit_code }

    # on success, run closure (if it has been set) and return
    if $result.exit_code == 0 {
        if $on_success != null { do $on_success $result.stdout } else { $result.stdout | str trim } | return $in
    }

    # if ignoring errors, return the $result object
    if $ignore_errors { $result.stdout | str trim | return $in }

    # if we get here, the operation failed
    # if $dump_result is set, dump the result object (it won't show unless BF_DEBUG is 1)
    if $dump_result != null { $result | dump -t $dump_result }

    # run closure (if it has been set) and return
    if $on_failure != null {
        do $on_failure $result.exit_code $result.stderr | return $in
    }

    # simply write the error
    ^bf-write-error --code $result.exit_code ($result.stderr | str trim) $script
}
