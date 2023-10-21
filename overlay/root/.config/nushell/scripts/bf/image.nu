use fs.nu

# Output information about the current image including name and version
export def main [] {
    # read image values
    cd /etc/bf
    let alpine = (fs read ALPINE)
    let image = (fs read IMAGE)
    let version = (fs read VERSION)

    # output a border above and below the image information
    let border = {|| let s = "="; 0..116 | reduce -f "" {|x, acc| $acc + $s } | $"(char newline)#($in)#(char newline)" | print }

    # output image info
    do $border
    $"bfren | ($image)" | ^figlet
    "" | print
    $"bfren/($image):($version) \(alpine:($alpine) nushell:(nu -v)\)" | print
    $"Built on (ls IMAGE | first | get modified)" | print
    "" | print
    $"https://github.com/bfren/docker-($image)" | print
    do $border
}
