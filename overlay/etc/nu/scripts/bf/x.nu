use dump.nu
use write.nu

# Set BF_X to the name of the script and then execute it
export def main [
    path: string    # Absolute path to the file to execute
]: nothing -> nothing {
    # if the file path is long, use the filename instead of the full path
    let name = if ($path | str length) > 15 { $path | path basename } else { $path }

    # set X variable and execute script
    with-env { BF_X: $name } {
        # execute script and capture result
        let result = do { ^nu $path } | complete

        # get and trim result values
        let exit_code = $result.exit_code
        let stdout = $result.stdout | str trim
        let stderr =  $result.stderr | str trim

        # on success show stdout
        if $exit_code == 0 {
            if ($stdout | is-not-empty) { $stdout | print }
            return
        }

        # show stdout and stderr
        if ($stdout | is-not-empty) { $stdout | dump --always }
        if ($stderr | is-not-empty) { $stderr | dump --always --stderr }

        # exit with result error code
        write error --code $exit_code $"Error while running ($name)."
    }
}
