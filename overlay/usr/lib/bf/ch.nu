use filesystem.nu
use print.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    ...glob: string             # The paths to which to apply ch operations
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r): bool        # If type is not specified, adds -R to recurse
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

    # set ownership
    if $owner != null {
        set_ownership $owner $recurse $filtered
    }

    # set mode
    if $mode != null {
        set_mode $mode $recurse $filtered
    }
}

def set_ownership [
    owner: string
    recurse: bool
    paths: list<string>
] {
    print debug $"Applying chown ($owner)..." "ch/set_ownership"

    if $recurse {
        print debug " .. recursively" "ch/set_ownership"
        chown -R $owner $paths
    } else {
        $paths | each { |x|
            print debug $" .. ($x)" "ch/set_ownership"
            chown $owner $x
        }
    }

    print debug_done "ch/set_ownership"
}

def set_mode [
    mode: string
    recurse: bool
    paths: list<string>
] {
    print debug $"Applying chmod ($mode)..." "ch/set_mode"

    if $recurse {
        print debug " .. recursively" "ch/set_mode"
        chmod -R $mode $paths
    } else {
        $paths | each { |x|
            print debug $" .. ($x)" "ch/set_mode"
            chmod $mode $x
        }
    }

    print debug_done "ch/set_mode"
}
