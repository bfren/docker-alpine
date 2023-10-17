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
    #               ensure the path exists before getting information about it
    #               |                              use ls to convert input path to a list of actual paths
    #               |                              |                     use closure to filter by file type
    #               |                              |                     |                    get the file path ('name')
    #               |                              |                     |                    |                   start with an empty list
    #               |                              |                     |                    |                   |       append each list of names to the accumulator
    #               |___________________           |___________          |________________    |________           |_____  |________________________
    #$paths | where {|x| $x | path exists } | each {|x| ls -f $x | where {|y| do $filter $y } | get name } | reduce -f [] {|x, acc| $acc | append $x }

    $paths | each {|x| glob $x | where $filter } | reduce -f [] {|x, acc| $acc | append $x }
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
