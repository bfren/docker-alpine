use env.nu

# Dump input value if debug is enabled, then return original value
export def main [] {
    let input = $in
    if (env debug) { print $input }
    $input
}
