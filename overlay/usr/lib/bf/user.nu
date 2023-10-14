use print.nu

# Add a non-login user and group of the specified name, optionally specifying UID and GID
export def add [
    name: string      # The name of the user and group to add
    --uid: int = 1000 # The UID
    --gid: int        # The GID (default: UID)
] {
    print debug $"Adding user ($name) with UID ($uid) and GID ($gid | $uid)." "user/add"
    addgroup --gid ($gid | $uid) $name
    adduser --uid $uid --home $"/home/($name)" --disabled-login --disabled-password --ingroup $name $name
    print debug_done "user/add"
}
