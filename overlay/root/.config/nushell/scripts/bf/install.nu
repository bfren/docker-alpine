use ch.nu
use clean.nu
use env.nu
use fs.nu
use image.nu
use del.nu
use write.nu
use x.nu

# Run standard installation for the container:
#   - show bfren environment
#   - fix apk
#   - run container's installation script
#   - set permissions
#   - save image version info
#   - run cleanup
#   - output image info
export def main [] {
    # output BF config
    write "bfren platform environment variables." install
    env show

    # make sure apk is working correctly (fixes some strange 'no such file or directory errors' on apk FETCH)
    write "Running apk fix and verify." install
    do { ^apk fix } | ignore
    do { ^apk verify } | ignore

    # run install script in /tmp
    const install = /tmp/install
    if (fs is_not_file $install) { write error $"($install) does not exist." install }

    write $"Executing ($install)." install
    x $install

    # set permissions
    write "Setting permissions." install
    ch --owner root:root --mode 0555 --type f /usr/bin/bf
    const perms = /tmp/install-ch
    if ($perms | path exists) { ch apply_file $perms }

    # store versions
    write "Storing image information." install
    cd /etc/bf
    ^cat /etc/os-release | lines | parse "{key}={value}" | transpose -i -r -d | get VERSION_ID | save --force ALPINE
    $env.BF_IMAGE | str replace "docker-" "" | save --force IMAGE
    $env.BF_VERSION | save --force VERSION

    # clean installation files / caches etc
    write "Running cleanup."
    clean

    # all finished
    write ok "Installation complete." install
    image
}
