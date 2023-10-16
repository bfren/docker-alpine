use fs.nu
use write.nu

# Output information about the current image including name and version
export def main [] {
    # read image values
    let image = (fs read /BF_IMAGE)
    let version = (fs read /BF_VERSION)
    let alpine = (fs read /BF_ALPINE)

    # output a border above and below the image information
    let border = {|| let s = "="; 0..116 | reduce -f "" {|x, acc| $acc + $s } | print $"(char newline)#($in)#(char newline)" }

    # output image info
    do $border
    $"bfren | ($image)" | figlet
    write $"bfren ($image) v($version) \(alpine/($alpine)\)" init/image
    write $"https://github.com/bfren/docker-($image)" init/image
    do $border
}
