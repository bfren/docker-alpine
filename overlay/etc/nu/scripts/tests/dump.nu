use std/assert
use ../bf/dump.nu *


#======================================================================================================================
# main
#======================================================================================================================

# Run dump with --always in a child process so its printed output can be captured -
# the return value is ignored so only what dump prints is captured
def dump_e [
    input: string       # Value to pipe into dump
    --text: string      # Passed to dump --text
    --stderr            # Passed to dump --stderr
] {
    let text = if ($text | is-not-empty) { $"--text '($text)'" } else { "" }
    ^$nu.current-exe --no-config-file --commands $"use bf/dump.nu ; '($input)' | dump --always --stderr=($stderr) ($text) | ignore" | complete
}

export def main__returns_original_input [] {
    let input = random chars

    let result = $input | dump

    assert equal $input $result
}

export def main__outputs_header [] {
    let header = random chars
    let input = random chars

    let result = dump_e $input --text $header

    assert str contains $result.stdout $"#== ($header) ==#"
}

export def main__outputs_input [] {
    let input = random chars

    let result = dump_e $input

    assert str contains $result.stdout $input
}

export def main__uses_stderr [] {
    let input = random chars

    let result = dump_e $input --stderr

    assert str contains $result.stderr $input
}
