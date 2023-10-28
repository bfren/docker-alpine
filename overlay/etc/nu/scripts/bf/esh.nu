use dump.nu
use env.nu
use fs.nu
use handle.nu
use write.nu

# Generate output using input as an esh template
export def main [
    input: string   # Input file
    output?: string # Output file - if omitted the output will be returned instead of saved
] {
    # ensure template file exists
    if ($input | fs is_not_file) { write error $"Template file ($input) does not exist." esh }

    # dump esh output and write error message
    let on_failure = { write error $"Error using template ($input)." esh }
    let on_success = { if ($output | path exists) { write debug $"($output) created." esh } }

    # generate template
    #   and: return value if $output is not set
    #   or:  save to file if $output is set
    if $output == null {
        { ^esh $input } | handle -f $on_failure -d "esh - no output" esh
    } else {
        { ^esh -o $output $input } | handle -s $on_success -f $on_failure -d $"esh - output ($output)" esh
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
    write debug $" .. ($filename)" esh/template
    main $input $output
}
