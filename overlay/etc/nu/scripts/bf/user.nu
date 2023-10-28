use handle.nu
use write.nu

# Add a non-login user and group of the specified name, optionally specifying UID and GID
export def add [
    name: string            # The name of the user and group to add
    --uid (-u): int = 1000  # The UID
    --gid (-g): int         # The GID (default: UID)
] {
    # if GID is set, use it, otherwise use UID
    let use_gid = if $gid != null { $gid } else { $uid }
    write $"Adding user ($name) with UID ($uid) and GID ($use_gid)." user/add

    # add group and user
    let home = $"/home/($name)"
    {
        ^addgroup --gid ($use_gid) $name
        ^adduser --uid $uid --home $home --disabled-password --ingroup $name $name
    } | handle user/add

    # create links to Nushell files and directories
    create_nushell_links $name

    # return nothing
    return
}

# Create links between shared Nushell config and a user's config
export def create_nushell_links [
    name: string    # The user name
    home?: string   # The user's home directory (if not set defaults to /home/$name)
] {
    # create paths to directories
    let shared_nu = "/etc/nu"
    let user_home = if $home != null { $home } else { $"/home/($name)" }
    let user_nu = $"($user_home)/.config/nushell"

    # ensure user's Nushell config directory exists and they own it
    mkdir $user_nu
    ^chown $"($name):($name)" $user_nu

    # link the shared Nushell files and directories to the user's config directory
    ^ln -f $"($shared_nu)/config.nu" $"($user_nu)/config.nu"
    ^ln -f $"($shared_nu)/env.nu" $"($user_nu)/env.nu"
    #^ln -sf $"($shared_nu)/plugins" $"($user_nu)/plugins"
    ^ln -sf $"($shared_nu)/scripts" $"($user_nu)/scripts"
}
