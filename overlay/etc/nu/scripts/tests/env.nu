use std/assert
use ../bf/env.nu *


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
    let key = random chars | str lowercase
    let key_upper = $key | str uppercase
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
# apply_perms
#======================================================================================================================

export def apply_perms__makes_store_readable_but_only_writable_by_owner [] {
    let dir = mktemp --directory --tmpdir
    let file = $"($dir)/(random chars)"
    random chars | save $file
    ^chmod -R 0777 $dir

    apply_perms $dir
    let result = ls --long --directory $dir $file | get mode

    rm --force --recursive $dir
    assert equal ["rwxr-xr-x" "rwxr-xr-x"] $result "store is writable by group or others"
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


#======================================================================================================================
# store
#======================================================================================================================

# directory used by store (not exported by env.nu)
const store_dir = "/etc/bf/env.d"

# path to the env.nu submodule
const env_nu = path self ../bf/env.nu

export def store__saves_environment_variable [] {
    let key = random chars
    let value = random chars

    with-env {$key: $value} { store }
    let result = open --raw $"($store_dir)/($key)"
    rm --force $"($store_dir)/($key)"

    assert equal $value $result "store does not save environment variable"
}

export def store__saves_multi_line_value_without_creating_other_variables [] {
    let key = random chars
    let fake_key = random chars
    let value = $"first(char newline)($fake_key)=y(char newline)a/b=c(char newline)last"

    with-env {$key: $value} { store }
    let result = open --raw $"($store_dir)/($key)"
    let fake_saved = $"($store_dir)/($fake_key)" | path exists
    rm --force $"($store_dir)/($key)"

    assert equal $value $result "store does not save multi-line value"
    assert equal false $fake_saved "store saves a line of a multi-line value as a variable"
}

export def store__does_not_save_nushell_process_variables [] {
    let ignored = [ "CURRENT_FILE" "FILE_PWD" "LAST_EXIT_CODE" "NU_VERSION" "PROCESS_PATH" "PWD" ]
    $ignored | each {|x| rm --force $"($store_dir)/($x)" }

    ^true
    store
    let result = $ignored | where {|x| $"($store_dir)/($x)" | path exists }

    assert equal [] $result "store saves variables set by nu for the current process"
}


#======================================================================================================================
# set
#======================================================================================================================

export def set__saves_to_environment_and_store [] {
    let key = random chars
    let value = random chars
    let prefixed = $prefix + $key

    set $key $value
    let result_env = $env | get --optional $prefixed
    let result_file = open --raw $"($store_dir)/($prefixed)"
    rm --force $"($store_dir)/($prefixed)"

    assert equal $value $result_env "set does not add value to environment"
    assert equal $value $result_file "set does not persist value to store"
}

export def set__with_no_prefix__does_not_add_prefix [] {
    let key = random chars
    let value = random chars

    set --no-prefix $key $value
    let result_env = $env | get --optional $key
    let result_file = open --raw $"($store_dir)/($key)"
    rm --force $"($store_dir)/($key)"

    assert equal $value $result_env "set does not add unprefixed value to environment"
    assert equal $value $result_file "set does not persist unprefixed value to store"
}

export def set__empty_value__unsets_variable [] {
    let key = random chars
    let prefixed = $prefix + $key

    set $key "value"
    set $key ""
    let result_env = $env | get --optional $prefixed
    let result_exists = $"($store_dir)/($prefixed)" | path exists

    assert equal null $result_env "set with empty value does not remove value from environment"
    assert equal false $result_exists "set with empty value does not remove value from store"
}


#======================================================================================================================
# unset
#======================================================================================================================

export def unset__removes_from_environment_and_store [] {
    let key = random chars
    let prefixed = $prefix + $key

    set $key "value"
    unset $key
    let result_env = $env | get --optional $prefixed
    let result_exists = $"($store_dir)/($prefixed)" | path exists

    assert equal null $result_env "unset does not remove value from environment"
    assert equal false $result_exists "unset does not remove value from store"
}

export def unset__with_no_prefix__does_not_add_prefix [] {
    let key = random chars

    set --no-prefix $key "value"
    unset --no-prefix $key
    let result_env = $env | get --optional $key
    let result_exists = $"($store_dir)/($key)" | path exists

    assert equal null $result_env "unset does not remove unprefixed value from environment"
    assert equal false $result_exists "unset does not remove unprefixed value from store"
}

export def unset__variable_does_not_exist__does_not_error [] {
    let key = random chars

    unset $key

    assert equal null ($env | get --optional ($prefix + $key))
}


#======================================================================================================================
# load
#======================================================================================================================

export def load__loads_stored_variables_into_environment [] {
    let key = random chars
    let value = random chars
    let prefixed = $prefix + $key

    $value | save --force $"($store_dir)/($prefixed)"
    load
    let result = $env | get --optional $prefixed
    rm --force $"($store_dir)/($prefixed)"

    assert equal $value $result "load does not load stored variable into environment"
}

export def load__loads_multi_line_value [] {
    let key = random chars
    let value = $"first(char newline)second"
    let prefixed = $prefix + $key

    $value | save --force $"($store_dir)/($prefixed)"
    load
    let result = $env | get --optional $prefixed
    rm --force $"($store_dir)/($prefixed)"

    assert equal $value $result "load does not load all lines of a stored variable"
}


#======================================================================================================================
# x_set
#======================================================================================================================

export def x_set__with_override__sets_bf_x [] {
    let name = random chars

    x_set --override $name

    assert equal $name $env.BF_X "x_set does not use override"
}

export def x_set__with_prefix__adds_prefix [] {
    let name = random chars
    let x_prefix = random chars

    x_set $x_prefix --override $name

    assert equal $"($x_prefix)/($name)" $env.BF_X "x_set does not add prefix"
}

export def x_set__without_override__uses_current_file_basename [] {
    # CURRENT_FILE is set by nu and cannot be set manually, so run a script in a child process
    let dir = mktemp --directory
    let name = $"(random chars).nu"
    $"use ($env_nu) *\nx_set\nprint $env.BF_X" | save $"($dir)/($name)"

    let result = ^nu --no-config-file $"($dir)/($name)" | str trim
    rm --recursive --force $dir

    assert equal $name $result "x_set does not use CURRENT_FILE basename"
}

export def x_set__is_not_persisted_to_store [] {
    x_set --override (random chars)

    assert equal false ($"($store_dir)/BF_X" | path exists) "x_set persists BF_X to store"
}
