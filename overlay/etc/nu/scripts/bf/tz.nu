use fs.nu
use del.nu
use install.nu
use write.nu

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
] {
    # get path to timezone definiton
    let path = $"/usr/share/zoneinfo/($tz)"

    # install timezone package
    write debug "Installing tzdata packages." tz
    install add [--virtual .tz tzdata]

    # check the specified timezone exists
    if (fs is_not_file $path) {
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
    do { ^apk del .tz } | ignore
    del force /usr/share/zoneinfo/*
}
