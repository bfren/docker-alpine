use print.nu

const $init_d = "/etc/bf/init.d"

# Initialise the container by executing all scripts contained in /etc/bf/init.d
export def main [] {
    print debug "Initialising container."
    if ($init_d | path exists) { ls $init_d | get name | sort | each { |x| execute $x } }
    print debug "Init complete."
}

# Execute a script within the init.d directory
def execute [
    filename: string    # Name of script file (within init.d directory)
] {
    print $"($filename): Running..."
    nu $"($init_d)/($filename)"
    print debug $"($filename): Done."
}

# Output information about the current image including name and version
export def image [] {
    # read image values
    let image = cat /BF_IMAGE
    let version = cat /BF_VERSION
    let alpine = cat /BF_ALPINE

    # output image info
    $"bfren | ($image)" | figlet
    print $"bfren ($image) v($version) \(alpine/($alpine)\)" "bf-image"
    print $"https://github.com/bfren/docker-($image)" "bf-image"
}
