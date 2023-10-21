use env.nu
use fs.nu
use string.nu

const build_file = "BUILD"
const format = "{k}: {v}"

# Parse and return information from the build log
export def main [] { fs read $"(env ETC)/($build_file)" | lines | parse $format | transpose -i -r -d }

# Add an entry to the build log
export def add [
    key: string     # Key e.g. 'Arch'
    value: string   # Value e.g. 'linux/amd64'
] {
    string format {k: $key, v: $value} $format | save --append $"(env ETC)/($build_file)"
}

# Show information from the build log
export def show [] { main | print }
