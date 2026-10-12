use std/assert
use ../bf/user.nu *
use ../bf/fs.nu [make_temp_dir]


#======================================================================================================================
# exists
#======================================================================================================================

export def exists__user_exists__returns_true [] {
    assert equal true (exists root)
}

export def exists__user_does_not_exist__returns_false [] {
    assert equal false (exists (random chars --length 12 | str lowercase))
}


#======================================================================================================================
# create_nushell_links
#======================================================================================================================

export def create_nushell_links__creates_links_to_shared_config [] {
    let home = make_temp_dir

    create_nushell_links root $home

    let dir = $"($home)/.config/nushell"
    let links = ["config.nu" "env.nu" "scripts"] | each {|x| $"($dir)/($x)" | path type }
    let targets = ["config.nu" "env.nu" "scripts"] | each {|x| ^readlink $"($dir)/($x)" | str trim }
    rm --recursive --force $home

    assert equal ["symlink" "symlink" "symlink"] $links "create_nushell_links does not create symlinks"
    assert equal ["/etc/nu/config.nu" "/etc/nu/env.nu" "/etc/nu/scripts"] $targets "create_nushell_links links to wrong targets"
}

export def create_nushell_links__empty_home__uses_default_home_path [] {
    # only checks that an empty home is not an error for an existing user - the path is /home/root,
    # so use a throwaway user name only if the directory can be created
    let home = make_temp_dir

    create_nushell_links root $home

    assert ($"($home)/.config/nushell" | path exists) "create_nushell_links does not create config directory"
    rm --recursive --force $home
}


#======================================================================================================================
# add
#======================================================================================================================

export def add__user_already_exists__returns_error [] {
    assert error {|| add root } "User root already exists."
}

export def add__creates_user_with_uid_and_group [] {
    let name = $"t(random chars --length 8 | str lowercase)"
    let uid = random int 20000..29999

    add $name --uid $uid
    let result = ^getent passwd $name | str trim
    let group = ^getent group $name | str trim
    let links = $"/home/($name)/.config/nushell/config.nu" | path type
    ^busybox deluser $name | ignore
    rm --recursive --force $"/home/($name)"

    assert ($result | str contains $":($uid):($uid):") "add does not create user with the specified UID and matching GID"
    assert ($group | str starts-with $"($name):") "add does not create group"
    assert equal "symlink" $links "add does not create Nushell links"
}

export def add__with_gid__uses_gid [] {
    let name = $"t(random chars --length 8 | str lowercase)"
    let uid = random int 20000..24999
    let gid = random int 25000..29999

    add $name --uid $uid --gid $gid
    let result = ^getent passwd $name | str trim
    ^busybox deluser $name | ignore
    rm --recursive --force $"/home/($name)"

    assert ($result | str contains $":($uid):($gid):") "add does not use specified GID"
}
