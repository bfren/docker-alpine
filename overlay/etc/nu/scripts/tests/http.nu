use std assert
use ../bf http *


#======================================================================================================================
# download
#======================================================================================================================

export def download__uses_filename_when_destination_is_not_specified [] {
    let url = "https://github.com/bfren/docker-alpine.git"
    let dir = mktemp --directory --tmpdir
    cd $dir

    let result = download $url | ls $dir | length

    assert equal 1 $result
}

export def download__saves_to_destination [] {
    let url = "https://github.com/bfren/docker-alpine.git"
    let dir = mktemp --directory --tmpdir
    let destination = $"($dir)/(random chars)"
    cd $dir

    let result = download $url $destination | $destination | path exists

    assert equal true $result
}


#======================================================================================================================
# get_status
#======================================================================================================================

export def get_status__returns_correct_status [] {
    let status = random int 200..500

    let result = $"https://bfren.dev/status/($status)" | get_status
    let expect = $status

    assert equal $expect $result "get_status does not return correct status"
}

export def get_status__invalid_url__returns_400 [] {
    let result = random chars | get_status
    let expect = 400

    assert equal $expect $result "get_status does not return 400 for an invalid URL"
}


#======================================================================================================================
# test
#======================================================================================================================

export def test__valid_status__returns_true [] {
    let valid_statuses = 200..399

    let result = $valid_statuses | par-each {|x| $"https://bfren.dev/status/($x)" | test }
    let expect = $valid_statuses | each { true }

    assert equal $expect $result "test does not return true for all valid statuses"
}

export def test__invalid_status__returns_false [] {
    let invalid_statuses = 400..599

    let result = $invalid_statuses | par-each {|x| $"https://bfren.dev/status/($x)" | test }
    let expect = $invalid_statuses | each { false }

    assert equal $expect $result "test does not return false for all invalid statuses"
}
