use fs.nu
use write.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    ...paths: string            # The paths to which to apply ch operations
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # If type is not specified, adds -R to recurse
    --type (-t): string = "a"   # Apply to all (a), files only (f) or directories only (d)
] {
    # filter out paths that are not of the requested type
    let filtered_paths = match $type {
        "a" => { $paths }
        "d" => { fs only_dirs $paths }
        "f" => { fs only_files $paths }
        _ => { write error $"Unknown type: ($type)." ch }
    }

    # if everything has been filtered out, return
    if ($filtered_paths | length) == 0 {
        write "Nothing found to change." ch
        return
    }

    # set ownership
    if $owner != null {
        write "Applying ownership." ch
        $filtered_paths | each {|x|
            write debug $" .. chown ($owner) to ($x)" ch
            if $recurse { chown -R $owner $x } else { chown $owner $x }
        }
    }

    # set mode
    if $mode != null {
        write "Applying permissions." ch
        $filtered_paths | each {|x|
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
