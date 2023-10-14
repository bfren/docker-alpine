use filesystem.nu
use print.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    glob: list<string>          # The paths to which to apply ch operations
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # If type is not specified, adds -R to recurse
    --type (-t): string = "a"   # Apply to all (a), files only (f) or directories only (d)
] {
    # filter out paths that are not of the requested type
    let filtered = match $type {
        "a" => { $glob }
        "d" => { filesystem only_dirs $glob }
        "f" => { filesystem only_files $glob }
        _ => { print notok_error $"Unknown type: ($type)." "ch" }
    }

    # if everything has been filtered out, return
    if ($filtered | length) == 0 {
        print debug "Nothing found to change." "ch"
        return
    }

    print debug "Applying..." "ch"

    # set ownership
    if $owner != null {
        $filtered | each { |x|
            print debug $" .. chown ($owner) to ($x)" "ch"
            if $recurse { chown -R $owner $x } else { chown $owner $x }
        }
    }

    # set mode
    if $mode != null {
        $filtered | each { |x|
            print debug $" .. chmod ($mode) to ($x)" "ch"
            if $recurse { chmod -R $mode $x } else { chmod $mode $x }
        }
    }

    print debug_done "ch"
}
