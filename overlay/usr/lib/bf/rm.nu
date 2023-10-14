use print.nu

# Force and recursively remove all files and directories matching glob
export def force [
    glob: string    # Glob to match
    --files-only    # If set, only files will be deleted
] {
    let print_and_delete = { |x| print debug $" .. ($x)" "util/rmrf"; rm -rf $x }

    let $kind = "files" + if (! $files_only) { " and directories" }
    let $paths = if $files_only { glob --no-dir $glob } else { glob $glob }

    print debug $"Force deleting ($kind) matching ($glob)..." "util/rmrf"
    $paths | sort | each { do $print_and_delete $in }
    print debug_done "util/rmrf"
}
