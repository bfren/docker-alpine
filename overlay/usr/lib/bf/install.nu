use print.nu

# Run standard installation for a container -
#   - setting permissions
#   - fixing apk
#   - running container's installation script
#   - saving image version info
#   - running cleanup
export def main [] {
    # set permissions
    bf ch -o root:root -m 0555 -r /init $env.BF_BIN $env.BF_LIB
    bf ch -o root:root -m 1777 /etc/bf/src /tmp
    bf ch -o root:root -r /etc/bf/templates
    bf ch -m 0444 -t f /etc/bf/templates
    bf ch -m 0555 -t d /etc/bf/templates

    # make sure apk is working correctly (fixes some strange 'no such file or directory errors' on apk FETCH)
    apk fix
    apk verify

    # run install script in /tmp
    let install = "/tmp/install"
    if ($install | path type) != "file" {
        bf print notok_error $"($install) does not exist." "install"
    }

    bf print debug $"Executing ($install)..." "install"
    nu $install
    bf print ok_done "install"

    # store versions
    $env.ALPINE_REVISION | save --force /BF_ALPINE
    $env.BF_IMAGE | str replace "docker-" "" | save --force /BF_IMAGE
    $env.BF_VERSION | save --force /BF_VERSION
    bf-image

    # clear installation files / caches etc
    clear
}

# Clear temporary directories, caches and installation files.
export def clear [] {
    bf print debug "Deleting /install" "bf-clear"
    bf rm force /install

    bf print debug "Removing .empty files..." "bf-clear"
    bf rm force --files-only .empty

    bf print debug "Clearing caches" "bf-clear"
    bf rm force /tmp/* /var/cache/apk/* /var/cache/misc/*

    bf print debug_done "bf-clear"
}
