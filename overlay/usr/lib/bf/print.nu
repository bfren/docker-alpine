use env.nu

# Print text, optionally in a specified colour, with the current date / time and script name
def p [
    text: string    # The text to print
    colour: string  # ANSI colour code to use for the text
    script?: string # The name of the calling script or executable
] {
    # get the name of the base executable
    let $bf_e = $env | get -i BF_E

    # use BF_E or the calling script as the prefix
    let $prefix = if $script != null {
        if $bf_e != null {
            $"($bf_e): "
        } else {
            $"($script): "
        }
    } else if $bf_e != null {
        $"($bf_e): "
    }

    # if script and BF_E are both set, BF_E is the prefix, so use script as the suffix
    let $suffix = if $script != null {
        if $bf_e != null {
            $" \(($script)\)"
        }
    }

    # format date and print text
    let $date = date now | format date "%Y-%m-%d %H:%M:%S"
    print $"[bf] ($date) | (ansi $colour)($prefix)($text)($suffix)(ansi reset)"
}

# Print text in standard colour with the current date / time
export def main [
    text: string    # The text to print
    script?: string # The name of the calling script or executable
] {
    p $text "reset" $script
}

# Print text in green with the current date / time
export def ok [
    text: string    # The text to print
    script?: string # The name of the calling script or executable
] {
    p $text "green" $script
}

# Print text in red with the current date / time
export def notok [
    text: string    # The text to print
    script?: string # The name of the calling script or executable
] {
    p $text "red" $script
}

# Print text in grey with the current date / time, if BF_DEBUG is enabled
export def debug [
    text: string    # The text to print
    script?: string # The name of the calling script or executable
] {
    if (env check BF_DEBUG) {
        let $colour = "grey"
        let $output = p $text $colour $script
        print --no-newline $"(ansi $colour)($output)(ansi reset)"
    }
}
