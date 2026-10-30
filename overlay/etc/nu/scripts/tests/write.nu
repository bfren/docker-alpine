use std/assert

const write_nu = path self ../bf/write.nu

# run a write command in a child process and return the output (with ANSI codes stripped, unless --raw is set)
def capture [command: string, --vars: record = {}, --raw]: nothing -> string {
    let output = with-env $vars { ^nu --no-config-file --commands $"use ($write_nu); ($command)" }
    if $raw { $output } else { $output | ansi strip }
}


#======================================================================================================================
# main
#======================================================================================================================

export def main__writes_text [] {
    let result = capture 'write "hello"'

    assert ($result | str contains "hello") "write does not output text"
    assert ($result | str starts-with "[bf] ") "write does not output [bf] prefix"
}

export def main__with_script__writes_script_prefix [] {
    let result = capture 'write "hello" my-script'

    assert ($result | str contains "my-script | hello") "write does not output script prefix"
}

export def main__with_bf_x__uses_bf_x_as_prefix [] {
    let result = capture 'write "hello"' --vars {BF_X: "my-executable"}

    assert ($result | str contains "my-executable | hello") "write does not use BF_X as prefix"
}

export def main__with_script_and_bf_x__uses_script_as_suffix [] {
    let result = capture 'write "hello" my-script' --vars {BF_X: "my-executable"}

    assert ($result | str contains "my-executable | hello (my-script)") "write does not use script as suffix"
}


#======================================================================================================================
# debug
#======================================================================================================================

export def debug__debug_enabled__writes_text [] {
    let result = capture 'write debug "hello"' --vars {BF_DEBUG: "1"}

    assert ($result | str contains "hello") "write debug does not output text when BF_DEBUG is 1"
}

export def debug__debug_not_enabled__writes_nothing [] {
    let result = capture 'write debug "hello"' --vars {BF_DEBUG: "0"}

    assert equal "" ($result | str trim) "write debug outputs text when BF_DEBUG is not 1"
}


#======================================================================================================================
# ok / notok / warn
#======================================================================================================================

export def ok__writes_text [] {
    assert ((capture 'write ok "hello"') | str contains "hello")
}

export def notok__writes_text [] {
    assert ((capture 'write notok "hello"') | str contains "hello")
}

export def warn__writes_text [] {
    assert ((capture 'write warn "hello"') | str contains "hello")
}

export def ok__uses_green [] {
    let result = capture --raw 'write ok "hello"'

    assert ($result | str contains (ansi green)) "write ok does not use green"
}

export def notok__uses_red [] {
    let result = capture --raw 'write notok "hello"'

    assert ($result | str contains (ansi red_bold)) "write notok does not use red"
}

export def warn__uses_yellow [] {
    let result = capture --raw 'write warn "hello"'

    assert ($result | str contains (ansi yellow)) "write warn does not use yellow"
}


#======================================================================================================================
# error
#======================================================================================================================

export def error__writes_text_and_throws [] {
    let result = try { capture 'write error "hello"'; "no error" } catch {|e| $e.msg }

    assert ($result != "no error") "write error does not throw"
}
