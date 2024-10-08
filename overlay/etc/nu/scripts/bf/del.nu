use dump.nu
use fs.nu
use write.nu

# Delete files or directories within root_dir older than $duration
export def old [
    root_dir: string    # The root directory - files / directories within this will be deleted
    duration: duration  # If a file or directory is older than this duration it will be deleted
    --live              # If not set, the paths to be deleted will be printed but not actually deleted
    --type (-t): string # The type of path to delete, either 'd' (directory) or 'f' (file)
] {
    # duration must be set
    if ($duration | is-empty) { write error "Duration must be set." del/old }

    # ensure only valid types are used
    let use_type = match $type {
        "d" => { "dir" }
        "f" => { "file" }
        _ => { write error $"Unknown type: ($type)." del/old }
    }

    # process input values to use in query
    let expiry = (date now) - $duration
    let use_root_dir = $root_dir | str trim --char "/" --right | $"($in)/*" | into glob

    # perform deletion
    write debug $"Removing ($use_type)s older than ($expiry)." del/old
    let print_and_delete = {|x| write debug $" .. ($x.name)" del/old ; if $live { rm --force --recursive $x.name } }
    ls $use_root_dir | where type == $use_type and modified < $expiry | each {|x| do $print_and_delete $x }

    return
}
