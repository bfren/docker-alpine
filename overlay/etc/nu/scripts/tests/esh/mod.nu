use std/assert
use ../bf/esh.nu *


#======================================================================================================================
# main
#======================================================================================================================

export def main__outputs_correct_values [] {
    let template = "/etc/nu/scripts/tests/files/template.esh"
    let expect = "a81db67145fc91a2e07ab8f2d1062016f634aa2bf11d74af11709f9741c62be6"
    let e = { BF_YES: "yes", BF_NO: "no", BF_TRUE: "1", BF_FALSE: "0" }

    let result = with-env $e { esh $template } | hash sha256

    assert equal $expect $result
}


#======================================================================================================================
# quoting
#======================================================================================================================

const quotes = "/etc/nu/scripts/tests/files/quotes.esh"

# esh line 109: apostrophes in literal template text
export def main__preserves_apostrophes_in_text [] {
    let result = esh $quotes | lines

    assert equal ($result | get 0) "literal: 'quoted' word"
    assert equal ($result | get 1) "literal-start: 'quoted at start' and end'"
    assert equal ($result | get 2) "literal-double: it''s two"
    assert equal ($result | get 3) r#'literal-backslash: C:\path\to it's'#
}

# esh line 376: apostrophes in variables passed as arguments
export def main__preserves_apostrophes_in_variables [] {
    let result = ^esh $quotes "QUOTE=it's 'quoted'" | lines

    assert equal ($result | get 4) "variable: it's 'quoted'"
}
