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


#======================================================================================================================
# clean
#======================================================================================================================

# Run 'tz clean' against a temporary timezone definitions directory, with a stub apk that reports whether tzdata is
# installed - returns the number of definitions left, or nothing on Debian (whose tz.nu has no clean, and is
# replaced over this one, so clean is called in a separate process rather than imported)
def run_clean [
    tzdata_installed: bool  # Whether the stub apk reports tzdata as installed
]: nothing -> any {
    if not ("/etc/alpine-release" | path exists) { return }

    let root = mktemp --directory
    mkdir $"($root)/bin" $"($root)/zoneinfo/Europe"
    "london" | save $"($root)/zoneinfo/Europe/London"
    let info_code = if $tzdata_installed { 0 } else { 1 }
    $"#!/bin/sh\n[ \"$1\" = info ] && exit ($info_code)\nexit 0\n" | save $"($root)/bin/apk"
    ^chmod +x $"($root)/bin/apk"

    let cmd = $"use /etc/nu/scripts/bf/tz.nu; tz clean --dir ($root)/zoneinfo"
    let result = with-env {PATH: ($env.PATH | prepend $"($root)/bin")} { ^$nu.current-exe --no-config-file --commands $cmd | complete }
    let left = glob $"($root)/zoneinfo/**/*" --no-dir | length
    rm --recursive --force $root

    assert equal 0 $result.exit_code $"tz clean failed: ($result.stderr)"
    $left
}

export def clean__tzdata_installed__keeps_definitions [] {
    let left = run_clean true
    if ($left | is-empty) { return }

    assert equal 1 $left "timezone definitions should be kept when tzdata is installed"
}

export def clean__tzdata_not_installed__removes_definitions [] {
    let left = run_clean false
    if ($left | is-empty) { return }

    assert equal 0 $left "timezone definitions should be removed when tzdata is not installed"
}
