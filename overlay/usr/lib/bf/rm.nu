use fs.nu
use write.nu

# Force and recursively remove all files and directories matching glob
export def force [
    ...glob: string     # Glob to match
    --files-only (-f)   # If set, only files will be deleted
] {
    # get description and paths based on files_only flag
    let kind = "files" + if $files_only { "" } else { " and directories" }
    let paths = if $files_only { fs only_files $glob } else { $glob }

    # closure to write and delete a path
    let print_and_delete = {|x| write debug $" .. ($x)" rm/force; rm -rf $x }

    # loop through paths, write and delete
    write $"Force deleting ($kind) matching ($glob)." rm/force
    $paths | sort | each {|x| do $print_and_delete $x }
}

# Delete files or directories within root_dir older than a certain number of days
export def old [
    root_dir: string    # The root directory - files / directories within this will be deleted
    --days (-d): int    # If a file or directory is older than this number of days it will be deleted
    --live              # If not set, the paths to be deleted will be printed but not actually deleted
    --type (-t): string # The type of path to delete, either 'd' (directory) or 'f' (file)
] {
    # days cannot be a negative number
    if $days <= 0 {
        write notok_error "Days must be a whole number greater than 0." rm/old
    }

    # ensure only valid types are used
    let use_type = match $type {
        "d" => { "dir" }
        "f" => { "file" }
        _ => { write notok_error $"Unknown type: ($type)." rm/old }
    }

    # process input values to use in query
    let minutes_ago = $days * 24 * 60 | $"($in)min" | into duration | (date now) - $in
    let use_root_dir = $root_dir | str trim --char "/" --right | $"($in)/*"

    # perform deletion
    write $"Removing ($use_type)s older than ($days) days." rm/old
    let print_and_delete = {|x| write debug $" .. ($x.name)" rm/old; if $live { rm -rf $x.name } }
    ls $use_root_dir | where type == $use_type and modified < $minutes_ago | each {|x| do $print_and_delete $x }
}
