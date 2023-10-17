use dump.nu
use write.nu

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
    $env | get $"BF_($key)"
}

# Safely returns the value of an environment variable -
# if the variable doesn't exist, an empty string will be returned instead
export def safe [
    key: string # Environment variable key - the BF_ prefix will be added automatically
] {
    $env | get --ignore-errors $"BF_($key)"
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
    $env.BF_E = (get_executable $prefix)
}
