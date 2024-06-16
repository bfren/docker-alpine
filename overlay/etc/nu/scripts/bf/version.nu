use dump.nu

# Returns true if version is at least equal to minimum
export def is_at_least [
    minimum: string # The minimum version required
]: string -> bool {
    # use natural sort to ensure (e.g.) 1.2.10 comes below 1.2.5
    [$in $minimum] | sort --natural | first | $in == $minimum
}

# Bump the patch number of the specified version (e.g. 1.2.10 -> 1.2.11)
export def bump []: string -> string { $in | split row "." | $"($in.0).($in.1).($in.2 | into int | $in + 1)" }
