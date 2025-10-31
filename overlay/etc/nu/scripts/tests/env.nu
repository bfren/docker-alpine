use std assert
use ../bf env *


#======================================================================================================================
# main
#======================================================================================================================

export def main__case_matches__returns_value [] {
    let key = random chars
    let value = random chars

    let result = with-env {$key: $value} { env --no-prefix $key }

    assert equal $value $result "does not return correct value with case-sensitive key"
}

export def main__case_does_not_match__returns_default_value [] {
    let key = random chars | str downcase
    let key_upper = $key | str upcase
    let value = random chars
    let default_value = random chars

    let result = with-env {$key: $value} { env --no-prefix $key_upper $default_value }

    assert equal $default_value $result "does not return default value with case-sensitive key"
}

export def main__returns_value_for_prefixed_key [] {
    let key = random chars
    let prefixed_key = $prefix + $key
    let value = random chars

    let result = with-env {$prefixed_key: $value} { env $key }

    assert equal $value $result "does not return value for prefixed key"
}

export def main__with_no_prefix__returns_value_for_unprefixed_key [] {
    let key = random chars
    let value = random chars

    let result = with-env {$key: $value} { env --no-prefix $key }

    assert equal $value $result "does not return value for unprefixed key"
}

export def main__no_value__with_default__returns_default_value [] {
    let key = random chars
    let default_value = random chars

    let result = env $key $default_value

    assert equal $default_value $result "does not return default value when key is not set"
}

export def main__no_value__with_safe__returns_safe_string [] {
    let key = random chars

    let result = env --safe $key
    let expect = ""

    assert equal $expect $result "does not return empty string with key is not set"
}


#======================================================================================================================
# check
#======================================================================================================================

export def check__value_is_1__returns_true [] {
    let key = random chars

    let result = with-env {$key: "1"} { check -P $key }
    let expect = true

    assert equal $expect $result "check does not return true when value is '1'"
}

export def check__value_is_not_1__returns_false [] {
    let key = random chars

    let result = with-env {$key: (random chars)} { check -P $key }
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
    let result = with-env {BF_DEBUG: "1"} { debug }
    let expect = true

    assert equal $expect $result "debug does not return true when value is '1'"
}

export def debug__value_is_not_1__returns_false [] {
    let result = with-env {BF_DEBUG: (random chars)} { debug }
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

    let result = with-env {$key: ""} { empty -P $key }
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

    let result = with-env {$key: (random chars)} { empty -P $key }
    let expect = false

    assert equal $expect $result "empty does not return false when value is not empty"
}
