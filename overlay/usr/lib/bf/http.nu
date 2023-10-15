use print.nu

# Load a URL and return the HTTP status code
export def get_status [
    url: string # URL to load
] {
    try { http get --allow-errors --full $url | get status } catch { 400 }
}

# Test a URL and return whether or not it returns an error HTTP status code
export def test_url [
    url: string # URL to load
] {
    print debug $"Testing ($url)..." http/test_url
    let status = get_status $url
    if $status >= 200 and $status <= 399 {
        print debug " .. OK" http/test_url
    } else if $status >= 400 and $status <= 499 {
        print debug " .. client error" http/test_url
        exit 1
    } else {
        print debug " .. server error" http/test_url
        exit 1
    }
}
