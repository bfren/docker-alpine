use print.nu
use rm.nu

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
] {
    # get path to timezone definiton
    let path = $"/usr/share/zoneinfo/($tz)"

    # install timezone package
    print debug "Installing tzdata packages." "tz"
    apk add --no-cache --virtual .tz tzdata

    # check the specified timezone exists
    if ($path | path type) != "file" {
        clear
        print notok_error $"($tz) is not a recognise timezone." "tz"
    }

    # copy timezone info
    print $"Setting timezone to ($tz)..." "tz"
    cp $path /etc/localtime
    clear
    print ok_done "tz"
}

# Remove tzdata packages and info
def clear [] {
    print debug "Removing tzdata packages." "tz/clear"
    apk del .tz
    rm force /usr/share/zoneinfo/*
}
