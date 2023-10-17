use fs.nu
use write.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    ...paths: string            # The paths to which to apply ch operations
    --debug (-d)                # Override BF_DEBUG for this call
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # If type is not specified, adds -R to recurse
    --type (-t): string = "a"   # Apply to all (a), files only (f) or directories only (d)
] {
    # override debug
    if $debug {
        $env.BF_DEBUG = "1"
    }

    # filter a file record by specified type
    let filter = {|x|
        match $type {
            "a" => true
            "d" => ($x.type == "dir")
            "f" => ($x.type == "file")
            _ => false
        }
    }

    # expand paths and filter by file type:
    #
    #                  | begin with the list input paths (might be globs, actual files, directories, etc)
    #                  |
    #                  |                  | use ls to convert input path to a list of actual paths
    #                  |                  |
    #                  |                  |                     | use closure to filter by file type
    #                  |                  |                     |
    #                  |                  |                     |                 | get the file path ('name')
    #                  |                  |                     |                 |
    #                  |                  |                     |                 |                             | append each list of names to the accumulator
    #                  \______            \________             \_____________    \________                     \________________
    let filtered = $paths | each {|x| ls -f $x | where {|y| do $filter $y } | get name } | reduce {|x, acc| $acc | append $x }

    # if everything has been filtered out, return
    if ($filtered | length) == 0 {
        write "Nothing found to change." ch
        return
    }

    # output
    write $"Changing ($filtered | length) path\(s\)." ch

    # set ownership
    if $owner != null {
        $filtered | each {|x|
            write debug $" .. chown ($owner) to ($x)" ch
            if $recurse { chown -R $owner $x } else { chown $owner $x }
        }
    }

    # set mode
    if $mode != null {
        $filtered | each {|x|
            write debug $" .. chmod ($mode) to ($x)" ch
            if $recurse { chmod -R $mode $x } else { chmod $mode $x }
        }
    }

    # return nothing
    return
}

# Apply permissions using a ch.d file
export def apply_file [
    path: string    # Absolute path to the ch.d file to read
] {
    # check file exists
    if (fs is_not_file $path) {
        write notok $"($path) does not exist or is not a file." ch/apply_file
        return
    }

    # split by row and apply changes row by row
    write $"Applying ($path)." ch/apply_file
    open $path | from ssv --minimum-spaces 1 --noheaders | each {|x| $x | values | apply_row }

    # return nothing
    return
}

# Apply permissions for a row container in a ch.d file:
#   1. file / directory glob
#   2. owner (for chown)
#   3. optional: file mode (for chmod)
#   4. optional: directory mode (for chmod)
def apply_row [] {
    # we need at least two values: glob and owner
    let row = $in
    if ($row | length) < 2 {
        return
    }

    # get values - glob and owner are required, fmode and dmode are optional
    let glob = $row | get 0
    let owner = $row | get 1
    let fmode = $row | get -i 2
    let dmode = $row | get -i 3
    write debug $" .. ($glob) ($owner) ($fmode) ($dmode)" ch/apply_row

    # apply changes
    main --owner $owner $glob
    if $fmode != null { main --mode $fmode --type f $glob }
    if $dmode != null { main --mode $dmode --type d $glob }
}
