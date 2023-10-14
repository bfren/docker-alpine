use print.nu

# Force and recursively remove all files and directories matching glob
export def force [
    glob: string    # Glob to match
    --files-only    # If set, only files will be deleted
] {
    # get description and paths based on files_only flag
    let $kind = "files" + if $files_only { "" } else { " and directories" }
    let $paths = if $files_only { glob --no-dir $glob } else { glob $glob }

    # closure to print and delete a path
    let print_and_delete = { |x| print debug $" .. ($x)" "rm/force"; rm -rf $x }

    # loop through paths, print and delete
    print debug $"Force deleting ($kind) matching ($glob)..." "rm/force"
    $paths | sort | each { do $print_and_delete $in }
    print debug_done "rm/force"
}
