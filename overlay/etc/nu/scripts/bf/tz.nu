use fs.nu
use del.nu
use pkg.nu
use write.nu

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
] {
    # get path to timezone definiton
    let path = $"/usr/share/zoneinfo/($tz)"

    # install timezone package
    write debug "Installing tzdata packages." tz
    pkg install [--virtual .tz tzdata]

    # check the specified timezone exists
    if ($path | fs is_not_file) {
        clean
        write error $"($tz) is not a recognise timezone." tz
    }

    # copy timezone info
    write $"Setting timezone to ($tz)." tz
    cp $path /etc/localtime
    clean

    # return nothing
    return
}

# Remove tzdata packages and info
def clean [] {
    write debug "Removing tzdata packages." tz/clean
    pkg remove [.tz]
    del force /usr/share/zoneinfo/*
}
