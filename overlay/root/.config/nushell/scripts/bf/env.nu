use dump.nu
use write.nu

# Returns true if $key exists in the environment and is equal to 1
export def check [
    key: string # Environment variable key
] {
    (safe $key | into string) == "1"
}

# Returns true if the BF_DEBUG environment variable is set to 1
export def debug [] {
    check BF_DEBUG
}

# Safely return the value of an environment variable
export def safe [
    key: string # Environment variable key
] {
    $env | get --ignore-errors $key
}

# Sets the BF_E environment variable to the name of the currently executing script
export def-env set_executable [
    prefix?: string # If set, will be added before the name of the current script
] {
    $env.BF_E = (if $prefix != null { $"($prefix)/" } | $"($in)($env.CURRENT_FILE | path basename)")
}
