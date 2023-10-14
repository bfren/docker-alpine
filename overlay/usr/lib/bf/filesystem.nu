# Return only the paths that point to files that exist
export def only_files [
    paths: list<string> # List of paths
] {
    only "file" $paths
}

# Return only the paths that point to directories that exist
export def only_dirs [
    paths: list<string> # List of paths
] {
    only "dir" $paths
}

def only [
    type: string
    paths: list<string>
] {
    $paths | where { |x| $x | path exists } | where { |x| ($x | path type) == $type }
}
