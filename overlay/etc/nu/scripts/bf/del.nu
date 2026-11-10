use fs.nu
use write.nu

# Delete files or directories within root_dir older than $duration - hidden files and directories (names starting
# with '.') are never deleted, so markers such as Syncthing's .stfolder or a NAS's .snapshot are kept
export def old [
    root_dir: string    # The root directory - files / directories within this will be deleted
    duration: duration  # If a file or directory is older than this duration it will be deleted
    --live              # If not set, the paths to be deleted will be printed but not actually deleted
    --type (-t): string = "f"   # The type of path to delete, either 'd' (directory) or 'f' (file)
]: nothing -> any {
    # throw an error if root directory does not exist
    if ($root_dir | fs is_not_dir) { write error $"Directory ($root_dir) does not exist." del/old }

    # ensure only valid types are used
    let use_type = match $type {
        "d" => { "dir" }
        "f" => { "file" }
        _ => { write error $"Unknown type: ($type)." del/old }
    }

    # process input values to use in query
    let expiry = (date now) - $duration

    # perform deletion
    write debug $"Removing ($use_type)s older than ($expiry)." del/old
    # list the directory itself (not a glob) so an empty directory gives no rows instead of an error - without --all,
    # so hidden files and directories are never deleted
    let files_to_delete = ls $root_dir | where type == $use_type and modified older-than $duration
    if $live {
        $files_to_delete | each {|x|
             write debug $" .. ($x.name)" del/old
             rm --force --recursive $x.name
        }
        return
    }

    return $files_to_delete
}
