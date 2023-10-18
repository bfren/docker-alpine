use dump.nu
use fs.nu
use write.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    ...paths: string            # The paths to which to apply ch operations
    --debug (-d)                # Override BF_DEBUG for this call
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # Adds -R to chmod / chown to recurse (overrides type if that is set too)
    --type (-t): string         # Apply to directories (d), files (f) or symlinks (l)
] {
    # override debug
    if $debug { $env.BF_DEBUG = "1" }

    # if recurse is set, execute chmod/chown on each path with recursion
    if $recurse {
        execute --mode $mode --owner $owner $recurse $paths
        return
    }

    # if type is set, find all paths of type within each path and execute chmod/chown on them
    if $type != null {
        execute --mode $mode --owner $owner false (fs find_type_acc $paths $type)
        return
    }

    # otherwise, execute chmod/chown on each path
    execute --mode $mode --owner $owner false $paths
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
    if ($row | length) < 2 { return }

    # get values - glob and owner are required, fmode and dmode are optional
    let glob = $row | get 0
    let owner = $row | get 1
    let fmode = $row | get -i 2
    let dmode = $row | get -i 3
    write debug $" .. ($glob) ($owner) ($fmode) ($dmode)" ch/apply_row

    # apply ownership changes
    execute --owner $owner true [$glob]

    # apply mode changes
    if $fmode != null {
        execute --mode $fmode false (fs find $glob f)
    }
    if $dmode != null {
        execute --mode $dmode false (fs find $glob d)
    }
}

# Execute changes on a set of files
def execute [
    recurse: bool               # Whether or not to use chmod / chown -R switch
    paths: list<string>         # The list of paths to change
    --mode (-m): string         # Use chmod: set permissions to this mode
    --owner (-o): string        # Use chown: set ownership to this user & group
] {
    # if there are no paths to change, return
    if ($paths | length) == 0 {
        write "Nothing found to change." ch
        return
    }

    # output the number of paths to change
    write $"Changing ($paths | length) path\(s\)." ch

    # set ownership
    if $owner != null {
        $paths | dump -t "execute paths" | each {|x|
            if ($x | path exists) {
                write debug $" .. chown ($owner) to ($x)" ch
                if $recurse { chown -R $owner $x } else { chown $owner $x }
            } else {
                write debug $" .. ($x) does not exist"
            }
        }
    }

    # set mode
    if $mode != null {
        $paths | each {|x|
            if ($x | path exists) {
                write debug $" .. chmod ($mode) to ($x)" ch
                if $recurse { chmod -R $mode $x } else { chmod $mode $x }
            } else {
                write debug $" .. ($x) does not exist"
            }
        }
    }

    # return nothing
    return
}
