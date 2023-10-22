use env.nu
use fs.nu
use string.nu

const build_file = "BUILD"
const format = "{k}: {v}"

# Parse and return information from the build log
export def main [] { fs read $"(env ETC)/($build_file)" | lines | parse $format | transpose -i -r -d }

# Add an entry to the build log
export def add [
    key: string     # Key e.g. 'Platform'
    value: string   # Value e.g. 'linux/amd64'
] {
    # format the entry and add a newline so the next entry is added to the next line
    string format {k: $key, v: $value} $format | $in + "\n" | save --append $"(env ETC)/($build_file)"
}

# Show information from the build log
export def show [] { main | print }