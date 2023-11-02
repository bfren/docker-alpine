use dump.nu

# Set BF_X to the name of the script and then execute it
export def main [
    path: string            # Absolute path to the file to execute
] {
    let name = if ($path | str length) > 15 { $path | path basename } else { $path }
    with-env {BF_X: $name} { ^nu $path }
}
