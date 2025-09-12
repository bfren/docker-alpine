use dump.nu
use write.nu

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
