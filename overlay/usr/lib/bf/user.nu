use print.nu

# Add a non-login user and group of the specified name, optionally specifying UID and GID
export def add [
    name: string      # The name of the user and group to add
    --uid: int = 1000 # The UID
    --gid: int        # The GID (default: UID)
] {
    # if GID is set, use it, otherwise use UID
    let use_gid = if $gid { $gid } else { $uid }
    print debug $"Adding user ($name) with UID ($uid) and GID ($use_gid)." user/add

    # add group first
    addgroup --gid ($use_gid) $name
    adduser --uid $uid --home $"/home/($name)" --disabled-login --disabled-password --ingroup $name $name
    print debug_done user/add
}
