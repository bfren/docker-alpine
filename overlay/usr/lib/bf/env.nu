# Sets the BF_E environment variable to the name of the currently executing script
export def-env set_executable [] {
    $env.BF_E = $"($env.CURRENT_FILE | path basename)"
}

# Returns true if $key exists in the environment and is equal to 1
export def check [
    key: string # Environment variable key
] {
    $env | get -i $key
    ($env | get -i $key) == "1"
}