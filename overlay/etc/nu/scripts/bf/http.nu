use dump.nu
use write.nu

export def download [
    url: string             # URL to download
    destination?: string    # Optional destination
    --insecure (-i)         # Whether or not to allow insecure connections
]: nothing -> nothing {
    # use destination if set, otherwise get the name of the file being downloaded and save to cwd
    let file = match $destination {
        null => ($url | url parse | get path | path basename)
        _ => $destination
    }

    # get raw contents and force save
    http get --insecure=($insecure) --raw $url | save --force $file
}

# Return the status code for a given URL
export def get_status []: string -> int {
    let url = $in
    try { http get --allow-errors --full --redirect-mode m $url | get status } catch { 400 }
}

# Test a URL and return whether or not it gives an error HTTP status code
export def test []: string -> bool {
    let url = $in
    let status = $url | get_status
    $status >= 200 and $status <= 399
}
