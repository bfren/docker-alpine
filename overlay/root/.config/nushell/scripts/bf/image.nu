use fs.nu

# Output information about the current image including name and version
export def main [] {
    # read image values
    let image = (fs read /BF_IMAGE)
    let version = (fs read /BF_VERSION)
    let alpine = (fs read /BF_ALPINE)

    # output a border above and below the image information
    let border = {|| let s = "="; 0..116 | reduce -f "" {|x, acc| $acc + $s } | $"(char newline)#($in)#(char newline)" | print }

    # output image info
    do $border
    $"bfren | ($image)" | ^figlet
    "" | print
    $"bfren/($image) v($version) \(alpine:($alpine)\)" | print
    $"Built on (ls /BF_IMAGE | first | get modified)" | print
    "" | print
    $"https://github.com/bfren/docker-($image)" | print
    do $border
}
