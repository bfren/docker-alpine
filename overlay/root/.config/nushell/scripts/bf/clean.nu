use del.nu
use write.nu

# clean temporary directories, caches and installation files
export def main [] {
    write debug "Deleting installation scripts." clean
    del force /preinstall /install

    write debug "Removing .empty files." clean
    del force --files-only .empty

    write debug "cleaning caches." clean
    del force /tmp/* /var/cache/apk/* /var/cache/misc/*
}
