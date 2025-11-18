use std assert
use ../bf fs *
use ../bf dump *


#======================================================================================================================
# find_name
#======================================================================================================================

export def find_name__returns_list_of_matching_files [] {
    let file = mktemp
    let dir0 = make_temp_dir
    let dir1 = make_temp_dir
    let dir2 = make_temp_dir
    cp $file $dir0
    cp $file $dir1
    cp $file $dir2
    let expect = 3

    let result = find_name "/tmp" ($file | path basename) | length

    assert equal $expect $result
}

export def find_name__returns_list_of_matching_directories [] {
    let dir0 = make_temp_dir
    let dir1 = make_temp_dir
    let dir2 = make_temp_dir
    cp -r $dir0 $dir1
    cp -r $dir0 $dir2
    let expect = 3

    let result = find_name "/tmp" ($dir0 | path basename) "d" | length

    assert equal $expect $result
}

export def find_name__returns_empty_list_when_no_match [] {
    let expect = 0

    let result = find_name "/" (random chars) | length

    assert equal $expect $result
}

export def find_name__returns_empty_list_when_wrong_directory [] {
    let file = mktemp
    let dir0 = make_temp_dir
    let dir1 = make_temp_dir
    let dir2 = make_temp_dir
    cp $file $dir0
    cp $file $dir1
    cp $file $dir2
    let expect = 0

    let result = find_name "/etc" ($file | path basename) | length

    assert equal $expect $result
}


#======================================================================================================================
# find_type
#======================================================================================================================

export def find_type__returns_list_of_directories [] {
    let tmp = make_temp_dir
    cd $tmp
    let dir0 = make_temp_dir --local
    let dir1 = make_temp_dir --local
    let dir2 = make_temp_dir --local
    let expect = 4

    let result = find_type $tmp "d" | length

    assert equal $expect $result
}

export def find_type__returns_list_of_files [] {
    let tmp = make_temp_dir
    cd $tmp
    let file = mktemp --tmpdir-path=($tmp)
    let dir0 = make_temp_dir --local
    let dir1 = make_temp_dir --local
    let dir2 = make_temp_dir --local
    cp $file $dir0
    cp $file $dir1
    cp $file $dir2
    let expect = 4

    let result = find_type $tmp "f" | length

    assert equal $expect $result
}


#======================================================================================================================
# is_not_dir
#======================================================================================================================

export def is_not_dir__input_is_dir_returns_false [] {
    let dir = mktemp --directory

    let result = $dir | is_not_dir

    assert equal false $result
}

export def is_not_dir__input_is_file_returns_true [] {
    let file = mktemp

    let result = $file | is_not_dir

    assert equal true $result
}

export def is_not_dir__input_is_symlink_returns_true [] {
    let file = mktemp
    let link = mktemp
    rm --force $link
    ln -s $file $link

    let result = $link | is_not_dir

    assert equal true $result
}


#======================================================================================================================
# is_not_file
#======================================================================================================================

export def is_not_file__input_is_dir_returns_true [] {
    let dir = mktemp --directory

    let result = $dir | is_not_file

    assert equal true $result
}

export def is_not_file__input_is_file_returns_false [] {
    let file = mktemp

    let result = $file | is_not_file

    assert equal false $result
}

export def is_not_file__input_is_symlink_returns_true [] {
    let file = mktemp
    let link = mktemp
    rm --force $link
    ln -s $file $link

    let result = $link | is_not_file

    assert equal true $result
}


#======================================================================================================================
# is_not_symlink
#======================================================================================================================

export def is_not_symlink__input_is_dir_returns_true [] {
    let dir = mktemp --directory

    let result = $dir | is_not_symlink

    assert equal true $result
}

export def is_not_symlink__input_is_file_returns_true [] {
    let file = mktemp

    let result = $file | is_not_symlink

    assert equal true $result
}

export def is_not_symlink__input_is_symlink_returns_false [] {
    let file = mktemp
    let link = mktemp
    rm --force $link
    ln -s $file $link

    let result = $link | is_not_symlink

    assert equal false $result
}


#======================================================================================================================
# make_temp_dir
#======================================================================================================================

export def make_temp_dir__creates_dir [] {
    let expect = "dir"

    let result = make_temp_dir | path type

    assert equal $expect $result
}

export def make_temp_dir__creates_dir_in_tmp [] {
    let expect = "/tmp/"

    let result = make_temp_dir | str replace ($in | path basename) ""

    assert equal $expect $result
}

export def make_temp_dir__creates_dir_in_working_directory [] {
    let cwd = mktemp --directory
    let expect = $"($cwd)/"
    cd $cwd

    let result = make_temp_dir --local | str replace ($in | path basename) ""

    assert equal $expect $result
}


#======================================================================================================================
# read
#======================================================================================================================

export def read__expands_virtual_filename [] {
    let file = mktemp
    let contents = random chars
    $contents | save --force $file

    let result = read ($file | path basename)

    assert equal $contents $result
}

export def read__file_does_not_exist_throws_error [] {
    let file = $"/tmp/(random chars)"
    let msg = $"File does not exist: ($file)."

    let result = {|| read $file }

    assert error $result $msg
}

export def read__file_does_not_exist_with_quiet_returns_empty [] {
    let file = $"/tmp/(random chars)"
    let expect = ""

    let result = read --quiet $file

    assert equal $expect $result
}

export def read__returns_trimmed_file_contents [] {
    let file = mktemp
    let contents = random chars
    $" ($contents) " | save --force $file

    let result = read $file

    assert equal $contents $result
}
