use env.nu
use fs.nu
use write.nu

# clean temporary directories, caches and installation files
export def main [
    --caches: list<string> = [ "/var/cache/apk" ]   # list of cache directories to clean
    --tmpdirs: list<string> = [ "/tmp" ]            # list of temporary directories to clean
]: nothing -> nothing {
    # create a merged list of places to clean -
    # appending /* to each so we don't delete the actual directories
    let ensure_glob = $caches | append $tmpdirs | str trim --right --char="*" | str trim --right --char="/" | each {|x| $"($x)/*" }
    write debug $"Deleting ($ensure_glob | str join ', ')." clean
    rm --force --recursive ...$ensure_glob

    # search for .empty files
    let files = fs find_name "/" ".empty"
    if ($files | is-not-empty) {
        write debug "Deleting .empty files." clean
        rm --force ...$files
    }

    # remove installation files from published images
    if (env check PUBLISHING) {
        write debug "Deleting preinstallation script." clean
        rm --force /preinstall

        write debug "Deleting tests module." clean
        rm --force --recursive /etc/nu/scripts/tests
    }

    # return nothing
    return
}
