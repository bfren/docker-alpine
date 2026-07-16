use fs.nu
use write.nu

# Save an entry to a nu config file
export def main [
    config_dir?: string = "/etc/nu"   # Directory containing config file (no slash at end)
]: string -> nothing {
    # trim slash from end of input and ensure directory exists
    let dir = $config_dir | str trim --right --char '/'
    if ($dir | fs is_not_dir ) {
        write error $"Directory '($dir)' does not exist." config
        return
    }

    # append statement to config.nu file
    $"($in)(char newline)" | save --append $"($dir)/config.nu"
}

# Add a nu module so it is loaded by default with all new shells
export def use [
    name: string    # Module name - contained within /scripts directory
]: nothing -> nothing {
    write $"Adding '($name)' module to config.nu." config/use
    $"use ($name)" | main
}
