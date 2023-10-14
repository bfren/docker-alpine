use filesystem.nu
use print.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    ...glob: string             # The paths to which to apply ch operations
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # If type is not specified, adds -R to recurse
    --type (-t): string = "a"   # Apply to all (a), files only (f) or directories only (d)
] {
    if $recurse {
        apply --mode $mode --owner $owner --recurse $glob
    } else {
        apply --mode $mode --owner $owner --type $type $glob
    }
}

# Apply ownership or permissions values to files and directories matched by glob
export def apply [
    paths: list<string>         # The paths to which to apply ch operations
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # If type is not specified, adds -R to recurse
    --type (-t): string = "a"   # Apply to all (a), files only (f) or directories only (d)
] {
    # filter out paths that are not of the requested type
    let filtered = match $type {
        "a" => { $paths }
        "d" => { filesystem only_dirs $paths }
        "f" => { filesystem only_files $paths }
        _ => { print notok_error $"Unknown type: ($type)." "ch/apply" }
    }

    # if everything has been filtered out, return
    if ($filtered | length) == 0 {
        print debug "Nothing found to change." "ch/apply"
        return
    }

    print debug "Applying..." "ch/apply"

    # set ownership
    if $owner != null {
        $filtered | each { |x|
            print debug $" .. chown ($owner) to ($x)" "ch/apply"
            if $recurse { chown -R $owner $x } else { chown $owner $x }
        }
    }

    # set mode
    if $mode != null {
        $filtered | each { |x|
            print debug $" .. chmod ($mode) to ($x)" "ch/apply"
            if $recurse { chmod -R $mode $x } else { chmod $mode $x }
        }
    }

    print debug_done "ch/apply"
}

# Apply permissions using a ch.d file
export def apply_file [
    path: string    # The ch.d file to read
] {
    # check file exists
    if ($path | path type) != "file" {
        print notok $"File ($path) does not exist or is not a file." "ch/apply_file"
        return
    }

    # split by row and apply changes row by row
    print debug $"Applying ($path)..." "ch/apply_file"
    open $path | from ssv --minimum-spaces 1 --noheaders | each { |x| $x | values | apply_row }

    print debug_done "ch/apply_file"
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

    # apply changes
    main --owner $owner $glob
    if $fmode != null { main --mode $fmode --type f $glob }
    if $dmode != null { main --mode $dmode --type d $glob }
}
