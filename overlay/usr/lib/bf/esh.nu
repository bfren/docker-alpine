use print.nu

# Generate output using input as an esh template
export def main [
    input: string   # input file
    output: string  # output file
] {
    # ensure template file exists
    if ($input | path type) != "file" {
        print notok_error $"Template file ($input) does not exist." "esh"
    }

    # generate output file and display any errors
    let result = esh -o $output $input
    if $result == "" {
        print debug $"($output) created." "esh"
    } else {
        print notok_error $"Error using template: ($result)." "esh"
    }
}
