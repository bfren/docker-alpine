use env.nu
use fs.nu
use write.nu

# clean temporary directories, caches and installation files
export def main []: nothing -> nothing {
    write debug "Deleting caches." clean
    rm --force --recursive /tmp/* /var/cache/apk/*

    write debug "Deleting .empty files." clean
    fs find_name "/" ".empty" | rm --force ...$in

    if (env check PUBLISHING) {
        write debug "Deleting preinstallation script." clean
        rm --force /preinstall

        write debug "Deleting tests module." clean
        rm --force --recursive /etc/nu/scripts/tests
    }

    write ok "Done." clean
    return
}
