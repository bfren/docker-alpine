use std assert
use ../bf esh *


#======================================================================================================================
# main
#======================================================================================================================

export def main__outputs_correct_values [] {
    let template = "/tmp/files/template.esh"
    let expect = "fe65601e94b65eb9706998571ea2fe14ef3b054d277dbad4918795f723849d3b"

    let result = esh $template | hash sha256

    assert equal $expect $result
}
