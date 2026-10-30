use std/assert
use ../bf/ch.nu *
use ../bf/fs.nu [make_temp_dir]


#======================================================================================================================
# helpers
#======================================================================================================================

# Returns the octal mode of the input path
def mode []: string -> string { ^stat -c "%a" $in | str trim }

# Returns the uid:gid of the input path
def ids []: string -> string { ^stat -c "%u:%g" $in | str trim }

# Creates a directory (mode 700) containing a file (mode 600) and a sub-directory (mode 700)
def setup []: nothing -> record {
    let dir = make_temp_dir
    let file = $"($dir)/file"
    let sub = $"($dir)/sub"
    "" | save $file
    mkdir $sub
    ^chmod 600 $file
    ^chmod 700 $sub $dir
    {dir: $dir, file: $file, sub: $sub}
}


#======================================================================================================================
# main
#======================================================================================================================

export def main__mode_sets_mode_on_path [] {
    let x = setup

    ch --mode 640 $x.file

    assert equal "640" ($x.file | mode)
}

export def main__type_f_sets_mode_on_files_only [] {
    let x = setup

    ch --type f --mode 644 $x.dir

    assert equal "644" ($x.file | mode)
    assert equal "700" ($x.sub | mode)
}

export def main__type_d_sets_mode_on_directories_only [] {
    let x = setup

    ch --type d --mode 755 $x.dir

    assert equal "755" ($x.sub | mode)
    assert equal "600" ($x.file | mode)
}

export def main__recurse_sets_mode_on_everything [] {
    let x = setup

    ch --recurse --mode 750 $x.dir

    assert equal ["750" "750" "750"] [($x.dir | mode) ($x.sub | mode) ($x.file | mode)]
}

export def main__owner_sets_ownership [] {
    let x = setup

    ch --owner "1234:1234" $x.file

    assert equal "1234:1234" ($x.file | ids)
}

export def main__type_f_sets_ownership_on_files_only [] {
    let x = setup
    let sub_ids = $x.sub | ids

    ch --type f --owner "1234:1234" $x.dir

    assert equal "1234:1234" ($x.file | ids)
    assert equal $sub_ids ($x.sub | ids)
}


#======================================================================================================================
# apply
#======================================================================================================================

export def apply__fewer_than_two_values__does_nothing [] {
    let x = setup

    [$x.file] | apply

    assert equal "600" ($x.file | mode)
}

export def apply__owner_is_applied_recursively [] {
    let x = setup

    [$x.dir "1234:1234"] | apply

    assert equal ["1234:1234" "1234:1234" "1234:1234"] [($x.dir | ids) ($x.sub | ids) ($x.file | ids)]
}

export def apply__file_mode_is_applied_to_files_only [] {
    let x = setup

    [$x.dir "0:0" "644"] | apply

    assert equal "644" ($x.file | mode)
    assert equal "700" ($x.sub | mode)
}

export def apply__directory_mode_is_applied_to_directories_only [] {
    let x = setup

    [$x.dir "0:0" "" "755"] | apply

    assert equal "600" ($x.file | mode)
    assert equal "755" ($x.sub | mode)
    assert equal "755" ($x.dir | mode)
}

export def apply__file_and_directory_modes_are_both_applied [] {
    let x = setup

    [$x.dir "0:0" "644" "755"] | apply

    assert equal ["755" "755" "644"] [($x.dir | mode) ($x.sub | mode) ($x.file | mode)]
}

export def apply__path_does_not_exist__does_not_error [] {
    [$"/tmp/(random chars)" "0:0" "644" "755"] | apply
}
