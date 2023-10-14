use print.nu

# Remove all files and directories matching glob
export def rmrf [
    glob: string    # Glob to match
] {
    print debug $"Force deleting files and directories matching ($glob)..."
    let print_and_delete = { |x| print debug $" .. ($x)"; rm -rf $x }
    glob $glob | sort | each { do $print_and_delete $in }
    print debug_done
}
