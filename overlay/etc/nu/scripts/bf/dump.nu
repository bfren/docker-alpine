# Dump input value if debug is enabled, then return original value
export def main [
    --text (-t): string # Optional string to print before input
] {
    let input = $in
    if ($env | get --ignore-errors BF_DEBUG | into string) == "1" {
        if $text != null { $"(char newline)#== ($text) ==#" | print }
        $input | to nuon --indent 2 | print
    }
    $input
}
