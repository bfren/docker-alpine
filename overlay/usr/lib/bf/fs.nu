
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

# Execute a script
export def x [
    path: string    # Absolute path to the file to execute
] {
    chmod +x $path
    exec $path
}
