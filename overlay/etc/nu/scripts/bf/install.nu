use build.nu
use ch.nu
use clean.nu
use del.nu
use dump.nu
use env.nu
use fs.nu
use image.nu
use test.nu
use write.nu
use x.nu

# System directories that image overlays copy files into - COPY gives existing directories the permissions of the
# matching directories in the build context, which are 0777 when building from a Windows drive
const system_dirs = [
    "/"
    "/etc"
    "/usr"
    "/usr/bin"
    "/usr/lib"
    "/usr/local"
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/sbin"
    "/usr/share"
    "/var"
    "/var/lib"
]

# Run standard installation for the container:
#   - show build information
#   - show bfren environment
#   - run container's installation script
#   - set permissions
#   - store image info
#   - run cleanup
#   - output image info
export def main []: nothing -> nothing {
    # output build info
    write "Build information." install
    build show

    # output BF config
    write "bfren platform environment variables." install
    env show

    # set permissions
    write "Setting permissions." install
    secure_system_dirs
    env apply_perms
    let root = "root:root"
    ["/etc/nu" $root "0666" "0777"] | ch apply
    ["/init" $root "0500"] | ch apply
    ["/test" $root "0500"] | ch apply
    ["/tmp" $root "1777" "1777"] | ch apply
    ["/usr/bin/bf" $root "0555"] | ch apply

    # run install script in /tmp
    const install = "/tmp/install"
    if ($install | fs is_not_file) {
        write debug $"($install) does not exist." install
    } else {
        write $"Executing ($install)." install
        x $install
    }

    # store versions
    write "Storing image information." install
    cd (env ETC)
    env IMAGE | str replace "docker-" "" | save --force IMAGE
    env VERSION | save --force VERSION

    # clean installation files / caches etc
    write "Running cleanup."
    clean

    # all finished
    write ok "Installation complete." install
    image
}

# Remove group and other write permission from system directories that exist - e.g. Debian 13's adduser refuses to run
# if a directory on PATH is world-writable
export def secure_system_dirs [
    root: string = ""   # Prefix added to each directory, so tests can use a temporary directory
]: nothing -> nothing {
    let dirs = $system_dirs
        | each {|x| $"($root)($x)" }
        | where { fs is_dir }
    ^chmod go-w ...$dirs
}
