use fs.nu
use print.nu

# Force and recursively remove all files and directories matching glob
export def force [
    ...glob: string # Glob to match
    --files-only    # If set, only files will be deleted
] {
    # get description and paths based on files_only flag
    let kind = "files" + if $files_only { "" } else { " and directories" }
    let paths = if $files_only { fs only_files $glob } else { $glob }

    # closure to print and delete a path
    let print_and_delete = { |x| print debug $" .. ($x)" rm/force; rm -rf $x }

    # loop through paths, print and delete
    print $"Force deleting ($kind) matching ($glob)..." rm/force
    $paths | sort | each { |x| do $print_and_delete $x }
    print ok_done rm/force
}

# Delete files or directories within root_dir older than a certain number of days
export def old [
    root_dir: string    # The root directory - files / directories within this will be deleted
    days: int           # If a file or directory is older than this number of days it will be deleted
    type: string        # The type of path to delete, either 'd' (directory) or 'f' (file)
] {
    # days cannot be a negative number
    if $days <= 0 {
        print notok_error "Days must be a whole number greater than 0." rm/old
    }

    # ensure only valid types are used
    let use_type = match $type {
        "d" => { "dir" }
        "f" => { "file" }
        _ => { print notok_error $"Unknown type: ($type)." rm/old }
    }

    let minutes = $days * 24 * 60
}
