use dump.nu
use fs.nu
use handle.nu
use write.nu

# Generate output using input as an esh template
export def main [
    input: string   # Input file
    output?: string # Output file - if omitted the output will be returned instead of saved
]: nothing -> string {
    # debug message
    write debug $"Parsing esh template ($input)." esh

    # ensure template file exists
    if ($input | fs is_not_file) { write error $"Template ($input) does not exist." esh }

    # dump esh output and write error message
    let on_failure = {|c,e|
        $e | print --no-newline --stderr
        write error $"Error ($c) parsing template ($input)." esh
    }
    let on_success = {
        write debug $" .. output saved to ($output)." esh
    }

    # generate template
    #   and: return value if $output is not set
    #   or:  save to file if $output is set and return filename
    if ($output | is-empty) {
        { ^esh $input }
            | handle -f $on_failure esh
            | return $in
    } else {
        { ^esh -o $output $input }
            | handle -f $on_failure -s $on_success esh
            | return $output
    }
}
