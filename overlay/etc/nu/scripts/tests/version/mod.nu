use std assert
use ../bf version *


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
