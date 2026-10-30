use std/assert
use ../bf/handle.nu *


#======================================================================================================================
# main
#======================================================================================================================

# Returns a closure that writes ' out ' to stdout and ' err ' to stderr, then exits with $code
def cmd [
    code: int   # Exit code
]: nothing -> closure {
    {|| ^sh -c $"echo ' out '; echo ' err ' >&2; exit ($code)" }
}

export def main__success_returns_trimmed_stdout [] {
    let expect = "out"

    let result = cmd 0 | handle

    assert equal $expect $result
}

export def main__failure_raises_error_with_code_and_stderr [] {
    let expect = "3: err"

    let result = try { cmd 3 | handle ; "no error" } catch {|e| $e.msg }

    assert equal $expect $result
}

export def main__code_only_returns_exit_code_on_success [] {
    let result = cmd 0 | handle --code-only

    assert equal 0 $result
}

export def main__code_only_returns_exit_code_on_failure [] {
    let result = cmd 3 | handle --code-only

    assert equal 3 $result
}

export def main__ignore_error_returns_trimmed_stdout_on_failure [] {
    let expect = "out"

    let result = cmd 3 | handle --ignore-error

    assert equal $expect $result
}

export def main__ignore_success_returns_nothing_on_success [] {
    let result = cmd 0 | handle --ignore-success

    assert equal null $result
}

export def main__ignore_success_overrides_on_success [] {
    let result = cmd 0 | handle --ignore-success --on-success {|out| "called" }

    assert equal null $result
}

export def main__on_success_receives_untrimmed_stdout [] {
    let expect = " out \n"

    let result = cmd 0 | handle --on-success {|out| $out }

    assert equal $expect $result
}

export def main__on_success_is_not_called_on_failure [] {
    let result = try { cmd 3 | handle --on-success {|out| "called" } } catch {|e| "error" }

    assert equal "error" $result
}

export def main__on_failure_receives_code_and_stderr [] {
    let expect = {code: 3, err: " err \n"}

    let result = cmd 3 | handle --on-failure {|code, err| {code: $code, err: $err} }

    assert equal $expect $result
}

export def main__on_failure_is_not_called_on_success [] {
    let expect = "out"

    let result = cmd 0 | handle --on-failure {|code, err| "called" }

    assert equal $expect $result
}
