use std assert
use ../bf dump *


#======================================================================================================================
# main
#======================================================================================================================

export def main__returns_original_input [] {
    let input = random chars

    let result = $input | dump

    assert equal $input $result
}

export def main__outputs_header [] {
    let header = random chars
    let input = random chars

    let result = $input | dump --text $header | complete

    assert str contains $result.stdout $"#== ($header) ==#"
}

export def main__outputs_input [] {
    let input = random chars

    let result = $input | dump | complete

    assert str contains $result.stdout $input
}

export def main__uses_stderr [] {
    let input = random chars

    let result = $input | dump --stderr | complete

    assert str contains $result.stderr $input
}
