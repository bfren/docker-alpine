use del.nu
use dump.nu
use write.nu

# clean temporary directories, caches and installation files
export def main [] {
    write debug "Deleting preinstallation script." clean
    del force /preinstall

    write debug "Deleting .empty files." clean
    del force --filename .empty /

    write debug "Deleting caches." clean
    del force /tmp/* /var/cache/apk/*
}
