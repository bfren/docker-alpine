use std assert
use ../bf env *


#======================================================================================================================
# check
#======================================================================================================================

export def check__value_is_1__returns_true [] {
    let key = random chars

    let result = with-env { $key: "1" } { check -P $key }
    let expect = true

    assert equal $expect $result "check does not return true when value is '1'"
}

export def check__value_is_not_1__returns_false [] {
    let key = random chars

    let result = with-env { $key: (random chars) } { check -P $key }
    let expect = false

    assert equal $expect $result "check does not return false when value is not '1'"
}

export def check__value_is_not_set__returns_false [] {
    let key = random chars

    let result = check -P $key
    let expect = false

    assert equal $expect $result "check does not return false when value is not set"
}


#======================================================================================================================
# debug
#======================================================================================================================

export def debug__value_is_1__returns_true [] {
    let result = with-env { BF_DEBUG: "1" } { debug }
    let expect = true

    assert equal $expect $result "debug does not return true when value is '1'"
}

export def debug__value_is_not_1__returns_false [] {
    let result = with-env { BF_DEBUG: (random chars) } { debug }
    let expect = false

    assert equal $expect $result "debug does not return false when value is not '1'"
}

export def debug__value_is_not_set__returns_false [] {
    let result = do { hide-env BF_DEBUG ; debug }
    let expect = false

    assert equal $expect $result "debug does not return false when value is not set"
}


#======================================================================================================================
# empty
#======================================================================================================================

export def empty__value_is_empty__returns_true [] {
    let key = random chars

    let result = with-env { $key: "" } { empty -P $key }
    let expect = true

    assert equal $expect $result "empty does not return true when value is ''"
}

export def empty__value_is_not_set__returns_true [] {
    let key = random chars

    let result = empty -P $key
    let expect = true

    assert equal $expect $result "empty does not return false when value is not set"
}

export def empty__value_is_not_empty__returns_false [] {
    let key = random chars

    let result = with-env { $key: (random chars) } { empty -P $key }
    let expect = false

    assert equal $expect $result "empty does not return false when value is not empty"
}
