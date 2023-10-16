use write.nu

# Returns true unless path exists and is a file
export def is_not_file [
    path: string    # Absolute path to the file to check
] {
    ($path | path type) != "file"
}

# Return only the paths that point to files that exist
export def only_files [
    paths: list<string> # List of paths
] {
    only file $paths
}

# Return only the paths that point to directories that exist
export def only_dirs [
    paths: list<string> # List of paths
] {
    only dir $paths
}

# Returns only paths of the specified type
def only [
    type: string        # Path type, e.g. 'file' or 'dir'
    paths: list<string> # List of paths to filter
] {
    $paths | where {|x| $x | path exists } | where {|x| ($x | path type) == $type }
}

# Read a file, trim contents and return
export def read [
    path: string
] {
    # attempt to get full path
    let use_path = $path | path expand

    # ensure file exists
    if (is_not_file $use_path) {
        write error $"File does not exist: ($use_path)." fs/read
    }

    # get and trim raw contents
    open --raw $use_path | str trim
}

# Execute a script
export def-env x [
    path: string    # Absolute path to the file to execute
] {
    chmod +x $path
    let name = if ($path | str length) > 15 { $path | path basename } else { $path }
    with-env [BF_E $name] { nu $path }
}
