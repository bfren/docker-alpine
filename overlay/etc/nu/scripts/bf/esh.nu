use dump.nu
use env.nu
use fs.nu
use write.nu

# Generate output using input as an esh template
export def main [
    input: string   # input file
    output?: string  # output file
] {
    # ensure template file exists
    if ($input | fs is_not_file) { write error $"Template file ($input) does not exist." esh }

    # dump esh output and write error message
    let dump_output = {|x|
        $x | dump -t "esh output"
        write error $"Error using template ($input)." esh
    }

    # generate template
    #   and: return value if $output is not set
    #   or:  save to file if $output is set
    if $output == null {
        let result = do { ^esh $input } | complete
        if $result.exit_code == 0 {
            $result.stdout
        } else {
            do $dump_output $result
        }
    } else {
        let result = do { ^esh -o $output $input } | complete
        if ($result.exit_code == 0) and ($output | path exists) {
            write debug $"($output) created." esh
        } else {
            do $dump_output $result
        }
    }
}

# It is common to generate a file using an esh template in the /etc/bf/templates directory,
# so this makes that easier
export def template [
    filename: string
    output_dir: string
] {
    # build paths and ensure input file and output directory exist
    let input = $"(env ETC_TEMPLATES)/($filename).esh"
    let output = $"($output_dir)/($filename)"
    if ($input | fs is_not_file) { write error $"Template ($input) does not exist." esh/template }
    if ($output_dir | fs is_not_dir) { write error $"Output directory ($output_dir) does not exist." esh/template }

    # output debug message and generate file
    write debug $" .. ($filename)"
    main $input $output
}
