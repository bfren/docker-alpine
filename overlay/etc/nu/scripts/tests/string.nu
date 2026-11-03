use std/assert
use ../bf/string.nu *


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
    let unformatted = "a = {a} b = {b}"
    let expect = $"format does not throw an error when placeholder {b} is not in values"

    let result = {|| format $unformatted $values }

    assert error $result $expect
}

export def format__allows_values_containing_braces [] {
    let values = {a: '{"b":1}'}
    let unformatted = "a = {a}"
    let expect = 'a = {"b":1}'

    let result = format $unformatted $values

    assert equal $expect $result
}

export def format__throws_error_with_unmatched_placeholder_containing_hyphen [] {
    let unformatted = "a = {sub-domain}"
    let expect = $"format does not throw an error when placeholder {sub-domain} is not in values"

    let result = {|| format $unformatted {} }

    assert error $result $expect
}

export def format__does_not_replace_placeholders_inside_values [] {
    let values = {a: "{b}" b: (random chars)}
    let unformatted = "a = {a}"
    let expect = "a = {b}"

    let result = format $unformatted $values

    assert equal $expect $result
}
