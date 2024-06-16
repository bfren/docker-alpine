use std assert
use ../bf http *


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
