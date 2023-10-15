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
    print "Setting permissions..." install
    ch -o root:root -m 0555 -r $env.BF_BIN /init    # r+x
    ch -o root:root -m 0444 -r $env.BF_LIB          # r
    ch -o root:root -m 1777 /etc/bf/src /tmp        # r+w+x+s
    ch -o root:root -r /etc/bf/templates
    ch -m 0444 -t f /etc/bf/templates               # r
    ch -m 0555 -t d /etc/bf/templates               # r+x
    print done install

    # make sure apk is working correctly (fixes some strange 'no such file or directory errors' on apk FETCH)
    print "Running apk fix and verify..." install
    apk fix
    apk verify
    print done install

    # run install script in /tmp
    let install = "/tmp/install.nu"
    if (fs is_not_file $install) {
        print notok_error $"($install) does not exist." install
    }

    print $"Executing ($install)..." install
    nu $install
    print done install

    # store versions
    print "Storing image information..." install
    $env.ALPINE_REVISION | save --force /BF_ALPINE
    $env.BF_IMAGE | str replace "docker-" "" | save --force /BF_IMAGE
    $env.BF_VERSION | save --force /BF_VERSION
    init image
    print done install

    # clear installation files / caches etc
    print "Running cleanup..."
    clear
    print done install

    # all finished
    print ok "Installation complete." install
}

# Clear temporary directories, caches and installation files.
export def clear [] {
    print debug "Deleting /install" install/clear
    rm force /install

    print debug "Removing .empty files..." install/clear
    rm force --files-only .empty

    print debug "Clearing caches" install/clear
    rm force /tmp/* /var/cache/apk/* /var/cache/misc/*
}
