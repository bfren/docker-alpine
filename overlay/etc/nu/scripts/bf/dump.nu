# Dump input value if debug is enabled, then return original value
export def main [
    --text (-t): string # Optional string to print before input
    --always (-a)       # Always dump output even if BF_DEBUG is not "1"
    --stderr (-e)       # Print to stderr instead of stdout
]: any -> any {
    # capture input variable so we can reuse it
    let input = $in

    # check BF_DEBUG directly so dump can be used everywhere (including env.nu module)
    if $always or ($env | get --optional BF_DEBUG | into string) == "1" {
        # output optional text heading
        if ($text | is-not-empty) { $"(char newline)#== ($text) ==#" | print --stderr=($stderr) }

        # output as an expanded table
        $input | table --expand | print --stderr=($stderr)
    }

    # return the original input unchanged
    $input
}
