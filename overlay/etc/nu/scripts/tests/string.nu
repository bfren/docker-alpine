use std assert
use ../bf string *


#======================================================================================================================
# quote
#======================================================================================================================

export def quote__adds_double_quotes [] {
    let value = random chars
    let expect = $"\"($value)\""

    let result = $value | quote

    assert equal $expect $result
}


#======================================================================================================================
# format
#======================================================================================================================

export def format__replaces_placeholders_with_values [] {
    let a = random chars
    let b = random chars
    let values = {a: $a b: $b}
    let unformatted = "a = {a} b = {b}"
    let expect = $"a = ($a) b = ($b)"

    let result = format $unformatted $values

    assert equal $expect $result
}

export def format__throws_error_with_unmatched_placeholders [] {
    let a = random chars
    let values = {a: $a}
    let unformatted = "a = {a} b = {b} c = {c}"
    let expect = $"($unformatted) contains unmatched placeholders: {b}, {c}."

    let result = {|| format $unformatted $values }

    assert error $result $expect
}
