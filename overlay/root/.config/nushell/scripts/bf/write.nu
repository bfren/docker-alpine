const colour = "reset"
const colour_debug = "grey"
const colour_ok = "green"
const colour_notok = "red_bold"

# Write text, optionally in a specified colour, with the current date / time and script name
def p [
    text: string    # The text to write
    colour: string  # ANSI colour code to use for the text
    script?: string # The name of the calling script or executable
] {
    # get the name of the base executable
    let bf_e = $env | get --ignore-errors BF_E

    # use BF_E or the calling script as the prefix
    let prefix = if $script != null {
        if $bf_e != null {
            $"($bf_e): "
        } else {
            $"($script): "
        }
    } else if $bf_e != null {
        $"($bf_e): "
    }

    # if script and BF_E are both set, BF_E is the prefix, so use script as the suffix
    let suffix = if $script != null {
        if $bf_e != null {
            $" \(($script)\)"
        }
    }

    # format date and write text
    let date = date now | format date "%Y-%m-%d %H:%M:%S"
    print $"[bf] ($date) | (ansi $colour)($prefix)($text)($suffix)(ansi reset)"
}

# Write text in standard colour with the current date / time
export def main [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    p $text $colour $script
}

# Write text in grey with the current date / time, if BF_DEBUG is enabled
export def debug [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    if ($env | get --ignore-errors BF_DEBUG | into string) == "1" {
        p $text $colour_debug $script | print --no-newline $"(ansi $colour_debug)($in)(ansi reset)"
    }
}

# Write error text in red with the current date / time, and exit using code
export def error [
    error: string           # The error text to write
    script?: string         # The name of the calling script or executable
    --code (-c): int = 1    # The error code to emit after the message
] {
    notok $error $script | print --no-newline --stderr $in
    exit $code
}

# Write text in red with the current date / time
export def notok [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    p $text $colour_notok $script
}

# Write text in green with the current date / time
export def ok [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    p $text $colour_ok $script
}
