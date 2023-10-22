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
    let result = do { ^find $base_path -name $name -type $type } | complete
    if $result.exit_code > 0 { write error $"Unable to find ($name) in ($base_path): ($result.stderr)." fs/find_name }

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
    let result = do { ^find $base_path -type $type } | complete
    if $result.exit_code > 0 { write error $"Unable to find type ($type) in ($base_path): ($result.stderr)." fs/find_type }

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

# Make a temporary directory in /tmp
export def make_temp_dir [
    --local (-l)    # If set the temporary directory will be created in the current working directory
] {
    # move to requested root dir
    let root = if $local { $env.PWD } else { "/tmp" }
    cd $root

    # make temporary directory and capture output
    let result = do { ^mktemp -d tmp.XXXXXX } | complete
    if $result.exit_code > 0 { write error $"($result.stderr)." fs/make_temp_dir }

    # get absolute path to directory and ensure it exists
    let path = $"($root)/($result.stdout)"
    if not ($path | path exists) { write error "Unable to create temporary directory." fs/make_temp_dir }

    # return the path
    $path
}

# Read a file, trim contents and return
export def read [
    path: string
] {
    # attempt to get full path
    let use_path = $path | path expand

    # ensure file exists
    if (is_not_file $use_path) { write error $"File does not exist: ($use_path)." fs/read }

    # get and trim raw contents
    open --raw $use_path | str trim
}