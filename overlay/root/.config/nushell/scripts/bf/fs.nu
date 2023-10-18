use write.nu

# Check $type is valid (i.e. supported by posix find)
def check_type [
    type: string    # Type to check - supported are directories (d), files (f) or symlinks (l)
] {
    match $type {
        "d" | "f" | "l" => $type
        _ => { write error $"($type) is not supported." fs/find_type }
    }
}

# Find all paths called $name in $base_path
export def find_name [
    base_path: string   # Base path to search
    name: string        # Name to search within $base_path
    type: string = "f"  # Limit results to paths of this type - supported are directories (d), files (f) or symlinks (l)
] {
    # if the glob / file cannot be found, return an empty list
    if (glob $base_path | length) == 0 { return [] }

    # check type is valid
    check_type $type

    # use posix find to search for items of a type, and split by lines into a list
    let result = run-external --redirect-stdout "find" $base_path "-name" $name "-type" $type | complete
    if $result.exit_code > 0 {
        write error $"Unable to find ($name) in ($base_path): ($result.stderr)." fs/find_name
    }

    # split result by lines
    $result.stdout | lines
}

# Find all paths called $name in $base_paths and reduce to a single list
export def find_name_acc [
    base_paths: list<string>    # List of base paths to search
    name: string                # Name to search within $base_paths
    type: string = "f"          # Limit results to paths of this type - supported are directories (d), files (f) or symlinks (l)
] {
    $base_paths | each {|x| find_name $x $name $type } | reduce -f [] {|y, acc| $acc | append $y }
}

# Find all paths that are $type in $base_path
export def find_type [
    base_path: string   # Base path to search
    type: string        # Limit results to paths of this type - supported are directories (d), files (f) or symlinks (l)
] {
    # if the glob / file cannot be found, return an empty list
    if (glob $base_path | length) == 0 { return [] }

    # check type is valid
    check_type $type

    # use posix find to search for items of a type, and split by lines into a list
    let result = run-external --redirect-stdout "find" $base_path "-type" $type | complete
    if $result.exit_code > 0 {
        write error $"Unable to find type ($type) in ($base_path): ($result.stderr)." fs/find_type
    }

    # split result by lines
    $result.stdout | lines
}

# Find all paths that are $type in $base_paths
export def find_type_acc [
    base_paths: list<string>    # List of base paths to search
    type: string                # Limit results to paths of this type - supported are directories (d), files (f) or symlinks (l)
] {
    $base_paths | each {|x| find_type $x $type } | reduce -f [] {|y, acc| $acc | append $y }
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
