use fs.nu
use write.nu

# Generate output using input as an esh template
export def main [
    input: string   # input file
    output: string  # output file
] {
    # ensure template file exists
    if (fs is_not_file $input) {
        write error $"Template file ($input) does not exist." esh
    }

    # generate output file and display any errors
    let result = do { ^esh -o $output $input } | complete
    if ($result.exit_code == 0) and ($output | path exists) {
        write debug $"($output) created." esh
    } else {
        write error $"Error using template: ($result.stderr)." esh
    }
}
