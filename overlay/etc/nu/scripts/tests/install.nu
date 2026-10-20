use std/assert
use ../bf/install.nu
use ../bf/fs.nu [make_temp_dir]


#======================================================================================================================
# secure_system_dirs
#======================================================================================================================

# Create system directories in a temporary root, with the given permissions
def make_dirs [
    dirs: record    # Directory (relative to the root) and its permissions
]: nothing -> string {
    let root = make_temp_dir
    ^chmod 0755 $root
    $dirs | transpose dir mode | each {|x|
        mkdir $"($root)($x.dir)"
        ^chmod $x.mode $"($root)($x.dir)"
    } | ignore
    $root
}

def mode [path: string]: nothing -> string { ^stat -c "%a" $path | str trim }

export def secure_system_dirs__removes_group_and_other_write_permission [] {
    let root = make_dirs {"/usr": "0777", "/usr/bin": "0775", "/etc": "0757"}

    install secure_system_dirs $root

    assert equal "755" (mode $"($root)/usr")
    assert equal "755" (mode $"($root)/usr/bin")
    assert equal "755" (mode $"($root)/etc")
}

export def secure_system_dirs__leaves_other_permissions_alone [] {
    let root = make_dirs {"/var": "0700", "/usr": "0751"}

    install secure_system_dirs $root

    assert equal "700" (mode $"($root)/var")
    assert equal "751" (mode $"($root)/usr")
}

export def secure_system_dirs__skips_symlinks_and_missing_directories [] {
    let root = make_dirs {"/usr": "0755", "/usr/bin": "0777"}
    ^ln -s bin $"($root)/usr/sbin"

    # most directories in the list do not exist in $root - chmod would fail if they were not skipped
    install secure_system_dirs $root

    assert equal "755" (mode $"($root)/usr/bin")
}
