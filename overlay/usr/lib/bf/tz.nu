use fs.nu
use rm.nu
use write.nu

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
] {
    # get path to timezone definiton
    let path = $"/usr/share/zoneinfo/($tz)"

    # install timezone package
    write debug "Installing tzdata packages." tz
    apk add --no-cache --virtual .tz tzdata out> ignore

    # check the specified timezone exists
    if (fs is_not_file $path) {
        clear
        write notok_error $"($tz) is not a recognise timezone." tz
    }

    # copy timezone info
    write $"Setting timezone to ($tz)." tz
    cp $path /etc/localtime
    clear
}

# Remove tzdata packages and info
def clear [] {
    write debug "Removing tzdata packages." tz/clear
    apk del .tz out> ignore
    rm force /usr/share/zoneinfo/*
}
