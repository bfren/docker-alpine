use print.nu

# Force and recursively remove all files and directories matching glob
export def rmrf [
    glob: string    # Glob to match
] {
    print debug $"Force deleting files and directories matching ($glob)..." "util/rmrf"
    let print_and_delete = { |x| print debug $" .. ($x)" "util/rmrf"; rm -rf $x }
    glob $glob | sort | each { do $print_and_delete $in }
    print debug_done "util/rmrf"
}
