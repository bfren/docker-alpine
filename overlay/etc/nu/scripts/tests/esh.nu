use std/assert
use ../bf/esh.nu *


#======================================================================================================================
# main
#======================================================================================================================

export def main__outputs_correct_values [] {
    let template = "/etc/nu/scripts/tests/files/template.esh"
    let expect = "fe65601e94b65eb9706998571ea2fe14ef3b054d277dbad4918795f723849d3b"
    let e = { BF_YES: "yes", BF_NO: "no", BF_TRUE: "1", BF_FALSE: "0" }

    let result = with-env $e { esh $template } | hash sha256

    assert equal $expect $result
}
