use std assert
use ../bf build *
use ../bf string [format]


#======================================================================================================================
# main
#======================================================================================================================

export def main__parses_build_log [] {
    let k = random chars
    let v = random chars
    let tmpdir = mktemp --directory
    format $log_format {k: $k, v: $v} | save --force $"($tmpdir)/($build_file)"

    let result = with-env [BF_ETC $tmpdir] { build } | get $k
    let expect = $v

    assert equal $result $expect "incorrect value found"
}


#======================================================================================================================
# add
#======================================================================================================================

export def add__appends_key_and_value [] {
    let k = random chars
    let v = random chars
    let tmpdir = mktemp --directory

    let result = with-env [BF_ETC $tmpdir] { add $k $v } | open --raw $"($tmpdir)/($build_file)"
    let expect = format $log_format {k: $k, v: $v} | $"($in)\n"

    assert equal $result $expect "build log entry not saved correctly"
}
