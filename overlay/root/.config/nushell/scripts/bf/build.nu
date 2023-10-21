use env.nu
use fs.nu
use string.nu

const build_file = "BUILD"
const format = "{key}: {value}"

# Parse and return information from the build log
export def main [] { fs read $"(env ETC)/($build_file)" | lines | parse $format | transpose -i -r -d }

# Add an item to the build log
export def add [
    key: string     # Key e.g. 'Build Arch'
    value: string   # Value e.g. 'linux/amd64'
] {
    string format {key: $key, value: $value} $format | save --append $"(env ETC)/($build_file)"
}

# Show information from the build log
export def show [] { main | print }
