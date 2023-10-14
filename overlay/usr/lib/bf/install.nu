use ch.nu
use init.nu
use print.nu
use rm.nu

# Run standard installation for a container -
#   - setting permissions
#   - fixing apk
#   - running container's installation script
#   - saving image version info
#   - running cleanup
export def main [] {
    # set permissions
    ch -o root:root -m 0555 -r $env.BF_BIN /init    # r+x
    ch -o root:root -m 0444 -r $env.BF_LIB          # r
    ch -o root:root -m 1777 /etc/bf/src /tmp        # r+w+x+s
    ch -o root:root -r /etc/bf/templates
    ch -m 0444 -t f /etc/bf/templates               # r
    ch -m 0555 -t d /etc/bf/templates               # r+x

    # make sure apk is working correctly (fixes some strange 'no such file or directory errors' on apk FETCH)
    apk fix
    apk verify

    # run install script in /tmp
    let install = "/tmp/install.nu"
    if ($install | path type) != "file" {
        print notok_error $"($install) does not exist." "install"
    }

    print debug $"Executing ($install)..." "install"
    nu $install
    print ok_done "install"

    # store versions
    $env.ALPINE_REVISION | save --force /BF_ALPINE
    $env.BF_IMAGE | str replace "docker-" "" | save --force /BF_IMAGE
    $env.BF_VERSION | save --force /BF_VERSION
    init image

    # clear installation files / caches etc
    clear
}

# Clear temporary directories, caches and installation files.
export def clear [] {
    print debug "Deleting /install" "bf-clear"
    rm force /install

    print debug "Removing .empty files..." "bf-clear"
    rm force --files-only .empty

    print debug "Clearing caches" "bf-clear"
    rm force /tmp/* /var/cache/apk/* /var/cache/misc/*

    print debug_done "bf-clear"
}
