use std assert
use ../bf config *


#======================================================================================================================
# main
#======================================================================================================================

export def main__returns_error [] {
    let dir = $"/tmp/(random chars)"

    assert error {|| random chars | config $dir } $"Directory '($dir)' does not exist."
}

export def main__writes_to_config_file [] {
    let dir = mktemp --directory
    let file = $"($dir)/config.nu"
    let content = random chars

    let result = $content | config $dir | open --raw $file | str trim

    assert equal $content $result
}
