use write.nu

const env_dir = /etc/bf/env.d

# Save an environment variable to the S6 environment
export def-env main [
    key: string # Environment variable key name - the BF_ prefix will be added automatically
    value: any  # Environment variable value
] {
    # add the BF_ prefix
    let prefixed = $"BF_($key)"

    # save to current environment
    load-env {$prefixed: $value}

    # persist environment
    $value | save --force $"($env_dir)/($prefixed)"

    # output for debugging purposes
    write debug $"($prefixed)=($value)." env/set
}

# Load shared environment into the current $env
export def-env load [
    prefix?: string         # If $set_executable is added, $prefix will be added before the name of the current script
    --set-executable (-e)   # Whether or not to set BF_E to the current script
] {
    # load environment variables from shared directory
    ls $env_dir | each {|x| open $x.name | str trim | {($x.name | path basename | str upcase): $in} } | reduce -f {} {|y, acc| $acc | merge $y } | load-env

    # set current script
    if $set_executable { set_executable $prefix }
}

# Returns true if $key exists in the environment and is equal to 1
export def check [
    key: string # Environment variable key - the BF_ prefix will be added automatically
] {
    (safe $key | into string) == "1"
}

# Returns true if the BF_DEBUG environment variable is set to 1
export def debug [] {
    check DEBUG
}

# Returns the value of an environment variable
export def req [
    key: string # Environment variable key - the BF_ prefix will be added automatically
] {
    try {
        $env | get $"BF_($key)"
    } catch {
        write error $"Unable to get environment variable BF_($key)."
    }
}

# Safely returns the value of an environment variable -
# if the variable doesn't exist, an empty string will be returned instead
export def safe [
    key: string # Environment variable key - the BF_ prefix will be added automatically
] {
    $env | get --ignore-errors $"BF_($key)"
}

# Show all bfren platform environment variables
export def show [] {
    $env | transpose key value | where {|x| $x.key | str starts-with "BF_" } | | transpose -i -r -d | print
}

# Gets the name of the currently executing script
export def get_executable [
    prefix?: string # If set, will be added before the name of the current script
] {
    if $prefix != null { $"($prefix)/" } | $"($in)($env.CURRENT_FILE | path basename)"
}

# Sets the BF_E environment variable to the name of the currently executing script
export def-env set_executable [
    prefix?: string # If set, will be added before the name of the current script
] {
    main E (get_executable $prefix)
}
