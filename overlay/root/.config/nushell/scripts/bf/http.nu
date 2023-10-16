use write.nu

# Load a URL and return the HTTP status code, ignoring any errors along the way
export def get_status [
    url: string # URL to load
] {
    try { http get --allow-errors --full $url | get status } catch { 400 }
}

# Test a URL and return whether or not it gives an error HTTP status code
export def test_url [
    url: string # URL to load
] {
    # allow http errors to be printed to give as much info as possible to calling
    write debug $"Testing ($url)." http/test_url
    http get $url

    # if we get here the URL was loaded successfully
    write debug " .. OK" http/test_url
}
