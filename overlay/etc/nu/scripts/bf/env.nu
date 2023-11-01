use handle.nu
use write.nu

# Path to the environment variable store
const env_dir = "/etc/bf/env.d"

# bfren platform prefix for namespacing environment variables
const prefix = "BF_"

# Returns the value of an environment variable - if $default_value is not set and the variable does not exist,
# an error will be thrown
export def main [
    key: string         # Environment variable key - the BF_ prefix will be added automatically
    default_value?: any # Optional default value to use if the variable cannot be found
    --no-prefix (-P)    # Do not add the BF_ prefix
] {
    # add (or don't add!) the BF_ prefix
    let prefixed = if $no_prefix { $key } else { add_prefix $key }

    # return the value if it exists
    let value = safe --no-prefix $prefixed
    if $value != null { return $value }

    # return the default value if it is set
    if $default_value != null { return $default_value }

    # otherwise output with an error
    write error $"Unable to get environment variable ($prefixed)." env
}

# Adds the BF_ prefix to $key
def add_prefix [key: string] { $prefix + $key }

# Apply permissions for the environment variables directory -
# we do this directly using chmod so env can be used in the ch module
export def apply_perms [] { { ^chmod -R 0666 $env_dir } | handle -i }

# Returns true if $key exists in the environment and is equal to 1
export def check [
    key: string         # Environment variable key - the BF_ prefix will be added automatically
    --no-prefix (-P)    # Do not add the BF_ prefix
] {
    # add (or don't add!) the BF_ prefix
    let prefixed = if $no_prefix { $key } else { add_prefix $key }

    # return whether or not the key value equals 1
    (safe --no-prefix $prefixed | into string) == "1"
}

# Returns true if the BF_DEBUG environment variable is set to 1
export def debug [] { check DEBUG }

# Hide and remove an environment variable
export def --env hide [
    key: string         # Environment variable key name - the BF_ prefix will be added automatically
    --no-prefix (-P)    # Do not add the BF_ prefix
] {
    # add (or don't add!) the BF_ prefix
    let prefixed = if $no_prefix { $key } else { add_prefix $key }

    # hide from the current environment
    hide-env --ignore-errors $prefixed

    # delete persistence file
    rm --force $"($env_dir)/($prefixed)"

    # output for debugging purposes
    # don't bother for BF_X - there are lots of these otherwise!
    if $key != "X" { write debug $"($prefixed) removed." env/hide }
}

# Load shared environment into the current $env
export def --env load [
    x_prefix?: string       # If $set_executable is added, $prefix will be added before the name of the current script
    --set-executable (-x)   # Whether or not to set BF_X to the current script
] {
    # load environment variables from shared directory
    let loaded = { ^bf-withenv env } | handle env/load | lines | parse "{key}={val}" | transpose -i -r -d
    try { load-env $loaded }

    # set current script
    if $set_executable { x_set $x_prefix }
}

# Safely returns the value of an environment variable -
# if the variable doesn't exist, an empty string will be returned instead
export def safe [
    key: string         # Environment variable key - the BF_ prefix will be added automatically
    --no-prefix (-P)    # Do not add the BF_ prefix
] {
    # add (or don't add!) the BF_ prefix
    let prefixed = if $no_prefix { $key } else { add_prefix $key }

    # ignore errors when getting the variable
    $env | get --ignore-errors --sensitive ($prefixed)
}

# Save an environment variable to the bfren environment
export def --env set [
    key: string         # Environment variable key name - the BF_ prefix will be added automatically
    value: any          # Environment variable value
    --no-prefix (-P)    # Do not add the BF_ prefix
] {
    # add (or don't add!) the BF_ prefix
    let prefixed = if $no_prefix { $key } else { add_prefix $key }

    # save to current environment
    load-env {$prefixed: $value}

    # create persistence file and apply permissions
    $value | save --force $"($env_dir)/($prefixed)"
    apply_perms

    # output for debugging purposes
    write debug $"($prefixed)=($value)." env/set
}

# Show all bfren platform environment variables
export def show [] {
    $env | transpose key value | where {|x| $x.key | str starts-with $prefix } | | transpose -i -r -d | print
}

# Store incoming environment variables
export def store [] {
    # these environment variables are reserved, set only by nu
    const ignore = [
        CURRENT_FILE
        FILE_PWD
        PWD
    ]

    # load incoming environment, parse and save to environment directory
    ^env | lines | parse "{key}={val}" | each {|x| if $x.key not-in $ignore { $x.val | save --force $"($env_dir)/($x.key)" } } | ignore

    # apply permissions to files
    apply_perms
}

# Clears the BF_X environment variable
export def --env x_clear [] { hide X }

# Sets the BF_X environment variable to the name of the currently executing script
export def --env x_set [
    x_prefix?: string # If set, will be added before the name of the current script
] {
    # get name of current file
    let current_file = try { $env.CURRENT_FILE | path basename }
    if $current_file == null { write error "Unable to determine current file." env/x_set }

    # set prefixed variable
    let prefixed = add_prefix X
    load-env {$prefixed: (if $x_prefix != null { $"($x_prefix)/" } | $"($in)($current_file)")}
}
