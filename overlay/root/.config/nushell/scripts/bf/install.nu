use ch.nu
use clean.nu
use dump.nu
use fs.nu
use image.nu
use del.nu
use write.nu

# Run standard installation for a container:
#   - setting permissions
#   - fixing apk
#   - running container's installation script
#   - saving image version info
#   - running cleanup
export def main [] {
    # output BF config
    write "BF environment variables." install
    $env | transpose key value | where {|x| $x.key | str starts-with "BF_" } | print

    # set permissions
    write "Setting permissions." install
    ch -o root:root -m 0555 -r $env.BF_BIN /init    # r+x
    ch -o root:root -m 1777 /etc/bf/src /tmp        # r+w+x+s
    ch -o root:root -r /etc/bf/templates
    ch -m 0444 -t f /etc/bf/templates               # r
    ch -m 0555 -t d /etc/bf/templates               # r+x

    # make sure apk is working correctly (fixes some strange 'no such file or directory errors' on apk FETCH)
    write "Running apk fix and verify." install
    apk fix out> ignore
    apk verify out> ignore

    # run install script in /tmp
    const install = "/tmp/install"
    if (fs is_not_file $install) {
        write error $"($install) does not exist." install
    }

    write $"Executing ($install)." install
    fs x $install

    # store versions
    write "Storing image information." install
    $env.ALPINE_REVISION | save --force /BF_ALPINE
    $env.BF_IMAGE | str replace "docker-" "" | save --force /BF_IMAGE
    $env.BF_VERSION | save --force /BF_VERSION

    # clean installation files / caches etc
    write "Running cleanup."
    clean

    # all finished
    write ok "Installation complete." install
    image
}
