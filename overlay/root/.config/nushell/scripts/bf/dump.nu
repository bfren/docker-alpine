# Dump input value if debug is enabled, then return original value
export def main [] {
    let input = $in
    if ($env | get -i BF_DEBUG | into string) == "1" {
        print $input
    }
    $input
}
