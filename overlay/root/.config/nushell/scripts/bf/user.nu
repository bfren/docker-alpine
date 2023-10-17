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

    # add group first
    addgroup --gid ($use_gid) $name out> ignore
    adduser --uid $uid --home $"/home/($name)" --disabled-login --disabled-password --ingroup $name $name out> ignore

    # return nothing
    return
}
