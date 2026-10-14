use std/assert
use ../bf/version.nu *


#======================================================================================================================
# is_at_least
#======================================================================================================================

export def is_at_least__returns_true_when_input_equals_minimum [] {
    let value = "1.2.3"
    let minimum = "1.2.3"

    let result = $value | is_at_least $minimum

    assert equal true $result
}

export def is_at_least__returns_true_when_input_is_greater_than_minimum [] {
    let value = "1.10.10"
    let minimum = "1.10.3"

    let result = $value | is_at_least $minimum

    assert equal true $result

}

export def is_at_least__returns_false_when_input_is_less_than_minimum [] {
    let value = "1.2.3"
    let minimum = "1.10.3"

    let result = $value | is_at_least $minimum

    assert equal false $result
}


#======================================================================================================================
# bump
#======================================================================================================================

export def bump__increments_patch_number [] {
    let result = "1.2.3" | bump

    assert equal "1.2.4" $result
}

export def bump__increments_double_digit_patch_number [] {
    let result = "1.2.9" | bump

    assert equal "1.2.10" $result
}

export def bump__does_not_change_major_or_minor [] {
    let result = "10.20.0" | bump

    assert equal "10.20.1" $result
}
