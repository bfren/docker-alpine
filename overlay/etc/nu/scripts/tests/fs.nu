use std assert
use ../bf fs *


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
