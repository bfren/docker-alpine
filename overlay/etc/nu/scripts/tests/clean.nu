use std assert
use ../bf clean *
use ../bf fs [make_temp_dir]


#======================================================================================================================
# main
#======================================================================================================================

def clean_e [
    --cache: string
    --tmpdir: string
] {
    let tmp = $tmpdir | default (make_temp_dir)
    clean --caches [$cache | default (mktemp --directory --tmpdir-path=($tmp))] --tmpdirs [$tmp]
}

export def main__deletes_tmp [] {
    let tmpdir = make_temp_dir
    let file0 = mktemp --tmpdir-path=($tmpdir)
    let file1 = mktemp --tmpdir-path=($tmpdir)
    let tmpfiles = ls $tmpdir | length

    let result = clean_e --tmpdir ($tmpdir) | echo $tmpdir | ls | length

    assert not equal $tmpfiles $result
}

export def main__deletes_cache [] {
    let cache = make_temp_dir
    let file0 = mktemp --tmpdir-path=($cache)
    let file1 = mktemp --tmpdir-path=($cache)
    let tmpfiles = ls $cache | length

    let result = clean_e --cache ($cache) | echo $cache | ls | length

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
