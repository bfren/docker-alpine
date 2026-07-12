use std/assert
use bf/dump
use bf/esh *


#======================================================================================================================
# main
#======================================================================================================================

export def main__outputs_correct_values [] {
    let template = "/tmp/files/template.esh"
    let expect = ""

    let result = esh $template | dump -a -t "template output" | hash sha256

    assert equal $expect $result
}
