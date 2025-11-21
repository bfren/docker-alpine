use write.nu

# Set BF_X to the name of the script and then execute it
export def main [
    path: string    # Absolute path to the file to execute
]: nothing -> any {
    # if the file path is long, use the filename instead of the full path
    let name = if ($path | str length) > 15 { $path | path basename } else { $path }
    write debug $"Executing script: ($path)." x

    # set X variable and execute script
    with-env {BF_X: $name} { ^nu $path }
}
