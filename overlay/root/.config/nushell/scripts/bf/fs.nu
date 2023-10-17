use write.nu

# Filter a list of paths by type
export def filter [
    paths: list<string> # The paths to filter
    type: string        # All (a), files only (f) or directories only (d)
] {
    # filter a file record by specified type
    let filter = {|x|
        match $type {
            "a" => true
            "d" => { ($x | path type) == "dir" }
            "f" => { ($x | path type) == "file" }
            _ => false
        }
    }

    # expand paths and filter by file type:
    #              expand each path string using glob
    #              |                    use closure to filter expanded paths by type
    #              |                    |                             start with an empty list
    #              |                    |                             |       append each list of names to the accumulator
    #              |__________          |________________             |_____  |________________________
    $paths | each {|x| glob $x | where {|y| do $filter $y } } | reduce -f [] {|x, acc| $acc | append $x }
}

# Find things within a glob
export def find [
    glob: string    # Base glob to search
    type?: string   # Find directories (d), files (f), symlinks (l) or (a) everything
] {
    match $type {
        "d" | "f" | "l" => { run-external --redirect-stdout "find" $glob "-type" $type }
        "a" => { run-external --redirect-stdout "find" $glob }
        _ => { write error $"Unknown search type: ($type)." fs/find }
    } | lines
}

# Returns true unless path exists and is a file
export def is_not_file [
    path: string    # Absolute path to the file to check
] {
    ($path | path type) != "file"
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
export def x [
    path: string    # Absolute path to the file to execute
] {
    let name = if ($path | str length) > 15 { $path | path basename } else { $path }
    with-env [BF_E $name] { nu $path }
}
