use print.nu

# Attempt to load a URL and return status code
export def get_status [
    url: string # URL to load
] {
    print debug $"Testing URL ($url)." "http/get_status"
    try { http get --allow-errors --full $url | get status } catch { 400 }
}
