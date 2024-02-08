# Run test suite if nupm module and tests exist
export def main [] {
    # set paths to test directories
    let scripts_dir = "/etc/nu/scripts"
    let nupm_dir = $"($scripts_dir)/nupm"
    let tests_dir = $"($scripts_dir)/tests"

    # execute tests if the directories exist
    if ($nupm_dir | path exists) and ($tests_dir | path exists) {
        ^env -i nu -c $"use nupm test ; test --dir ($scripts_dir)"
    }
}
