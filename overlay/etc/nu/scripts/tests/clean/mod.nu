use std/assert
use ../bf/clean.nu *
use ../bf/fs.nu [make_temp_dir]


#======================================================================================================================
# main
#======================================================================================================================

# runs clean inside temporary directories, so tests never touch the rest of the filesystem
def clean_e [
    --cache: string
    --tmpdir: string
] {
    let tmp = if $tmpdir == null { make_temp_dir } else { $tmpdir }
    let cache = if $cache == null { make_temp_dir } else { $cache }
    clean --caches [$"($cache)/*"] --tmpdirs [$"($tmp)/*"] --root $tmp
}

export def main__deletes_tmp [] {
    let tmpdir = make_temp_dir
    let file0 = mktemp --tmpdir-path=($tmpdir)
    let file1 = mktemp --tmpdir-path=($tmpdir)
    let tmpfiles = ls $tmpdir | length

    let result = clean_e --tmpdir ($tmpdir) | ls $tmpdir | length

    assert not equal $tmpfiles $result
}

export def main__deletes_cache [] {
    let cache = make_temp_dir
    let file0 = mktemp --tmpdir-path=($cache)
    let file1 = mktemp --tmpdir-path=($cache)
    let tmpfiles = ls $cache | length

    let result = clean_e --cache ($cache) | ls $cache | length

    assert not equal $tmpfiles $result
}

export def main__deletes_dot_empty_files [] {
    let tmpdir = make_temp_dir
    let file0 = mktemp --directory --tmpdir-path=($tmpdir) | $"($in)/.empty"
    let file1 = mktemp --directory --tmpdir-path=($tmpdir) | $"($in)/.empty"
    random chars | save --force $file0
    random chars | save --force $file1

    let result = clean_e --tmpdir ($tmpdir) | (echo $file0 | path exists) or (echo $file1 | path exists)

    assert equal false $result
}

export def main__only_deletes_dot_empty_files_under_root [] {
    let root = make_temp_dir
    let other = make_temp_dir
    let inside = mktemp --directory --tmpdir-path=($root) | $"($in)/.empty"
    let outside = $"($other)/.empty"
    "" | save --force $inside
    "" | save --force $outside

    clean --caches [] --tmpdirs [] --root $root

    assert equal false ($inside | path exists)
    assert equal true ($outside | path exists)
}
