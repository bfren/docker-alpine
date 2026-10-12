use std/assert
use ../bf/tz.nu *


#======================================================================================================================
# current
#======================================================================================================================

export def current__returns_contents_of_timezone_file [] {
    let result = current
    let expected = open --raw /etc/timezone | str trim

    assert ($result | is-not-empty) "current returns an empty timezone"
    assert equal $expected ($result | str trim)
}
