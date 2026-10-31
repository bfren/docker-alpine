use std/assert
use ../bf/del.nu *


#======================================================================================================================
# old
#======================================================================================================================

export def old__directory_does_not_exist_returns_error [] {
    let root_dir = $"/tmp/(random chars)"
    let duration = random int | into duration
    let type = "d"
    let msg = $"Directory ($root_dir) does not exist."

    let result = {|| old --type $type $root_dir $duration }

    assert error $result $msg
}

export def old__unknown_type_returns_error [] {
    let root_dir = mktemp --directory
    let duration = random int | into duration
    let type = random chars
    let msg = $"Unknown type: ($type)."

    let result = {|| old --type $type $root_dir $duration }

    assert error $result $msg
}

export def old__live_not_set_returns_files_older_than_duration [] {
    let root_dir = mktemp --directory --tmpdir
    let duration = random int 5..10 | into duration --unit day
    let older_file = mktemp --tmpdir-path=($root_dir)
    let newer_file = mktemp --tmpdir-path=($root_dir)
    touch --timestamp ((date now) - $duration - 1day) $older_file
    touch --timestamp (date now) $newer_file
    let expect = [$older_file $newer_file] | sort --natural

    let result = old --type "f" $root_dir $duration | ls $root_dir | get name | sort --natural

    assert equal $expect $result
}

export def old__live_set_deletes_files_older_than_duration [] {
    let root_dir = mktemp --directory --tmpdir
    let duration = random int 5..10 | into duration --unit day
    let older_file = mktemp --tmpdir-path=($root_dir)
    let newer_file = mktemp --tmpdir-path=($root_dir)
    touch --timestamp ((date now) - $duration - 1day) $older_file
    touch --timestamp (date now) $newer_file

    let result = old --live --type "f" $root_dir $duration | ls $root_dir | get name | first

    assert equal $newer_file $result
}

export def old__type_not_set_returns_files [] {
    let root_dir = mktemp --directory --tmpdir
    let duration = random int 5..10 | into duration --unit day
    let older_file = mktemp --tmpdir-path=($root_dir)
    mkdir $"($root_dir)/(random chars)"
    touch --timestamp ((date now) - $duration - 1day) $older_file

    let result = old $root_dir $duration | get name

    assert equal [$older_file] $result
}
