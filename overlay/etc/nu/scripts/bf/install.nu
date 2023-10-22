use build.nu
use ch.nu
use clean.nu
use del.nu
use env.nu
use fs.nu
use image.nu
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
    # output build info
    write "Build information." install
    build show

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
    env apply_perms
    ["/etc/nu" "root:root" 0666 0777] | ch apply
    ["/usr/bin/bf" "root:root" 0555] | ch apply

    const perms = /tmp/install-ch
    if ($perms | path exists) { ch apply_file $perms }

    # store versions
    write "Storing image information." install
    cd (env ETC)
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

# Use apk to install a list of packages
export def add [
    packages: list<string>  # List of packages to isntall
] {
    # we need to do it like this because apk won't take a joined string directly
    let pkg = $packages | str join " "
    write debug $"Installing: ($pkg)." install/add
    let result = do { sh -c $"apk add --no-cache ($pkg)" } | complete

    # exit on error
    if $result.exit_code > 0 {
        $result.stderr | print
        write error --code $result.exit_code "Error installing packages." install/add
    }
}