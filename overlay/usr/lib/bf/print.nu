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

export def main [
    text: string
    script?: string
] {
    p $text "reset" $script
}

export def ok [
    text: string
    script?: string
] {
    p $text "green" $script
}

export def notok [
    text: string
    script?: string
] {
    p $text "red" $script
}

export def debug [
    text: string
    script?: string
] {
    if (env check BF_DEBUG) {
        let $colour = "grey"
        let $output = p $text $colour $script
        print --no-newline $"(ansi $colour)($output)(ansi reset)"
    }
}
