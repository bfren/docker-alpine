# Sets the BF_E environment variable to the name of the currently executing script
export def-env set_executable [
    override?: string   # If set, will override name of current script
] {
    $env.BF_E = if $override { $override } else { $"($env.CURRENT_FILE | path basename)" }
}

# Safely return the value of an environment variable
export def safe [
    key: string # Environment variable key
] {
    $env | get -i $key
}

# Returns true if $key exists in the environment and is equal to 1
export def check [
    key: string # Environment variable key
] {
    (safe $key) == "1"
}
