use fs.nu
use write.nu

# Generate output using input as an esh template
export def main [
    input: string   # input file
    output: string  # output file
] {
    # ensure template file exists
    if (fs is_not_file $input) {
        write notok_error $"Template file ($input) does not exist." esh
    }

    # generate output file and display any errors
    let result = esh -o $output $input
    if $result == "" {
        write debug $"($output) created." esh
    } else {
        write notok_error $"Error using template: ($result)." esh
    }
}
