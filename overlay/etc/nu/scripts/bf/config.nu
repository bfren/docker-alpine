use write.nu

# Save an entry to the main nu config file
export def main []: string -> nothing { $"($in)(char newline)" | save --append /etc/nu/config.nu }

# Add a module to config.nu so it is loaded by default with all new shells
export def use [
    name: string    # Module name - contained within /scripts directory
]: nothing -> nothing {
    write $"Adding ($name) module to config."
    $"use ($name)" | main
}
