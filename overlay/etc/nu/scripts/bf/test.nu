# Run test suite if nupm module and tests exist
export def main [] {
    let scripts_dir = "/etc/nu/scripts"
    let nuon_dir = $"($scripts_dir)/nupm"
    let tests_dir = $"($scripts_dir)/tests"
    if ($nuon_dir | path exists) and ($tests_dir | path exists) {
        ^env -i nu -c $"use nupm test ; test --dir ($scripts_dir)"
    }
}
