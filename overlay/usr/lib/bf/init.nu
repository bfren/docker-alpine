use write.nu

const $init_d = "/etc/bf/init.d"

# Initialise the container by executing all scripts contained in /etc/bf/init.d
export def main [] {
    write debug "Initialising container." init
    if ($init_d | path exists) { ls $init_d | get name | sort | each { |x| execute $x } }
    write debug "Init complete." init
}

# Execute a script within the init.d directory
def execute [
    filename: string    # Name of script file (within init.d directory)
] {
    write $"($filename): Running..." init/execute
    nu $"($init_d)/($filename)"
    write debug $"($filename): Done." init/execute
}

# Output information about the current image including name and version
export def image [] {
    # read image values
    let image = cat /BF_IMAGE
    let version = cat /BF_VERSION
    let alpine = cat /BF_ALPINE

    # output image info
    $"bfren | ($image)" | figlet
    write $"bfren ($image) v($version) \(alpine/($alpine)\)" init/image
    write $"https://github.com/bfren/docker-($image)" init/image
}
