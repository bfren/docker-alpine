use write.nu

# Perform a package action, capturing result and outputting any errors
def action [
    name: string
    description: string
    args: list<string>
    cmd: string
] {
    # add pkg to the script name
    let script = $"pkg/($name)"

    # we need to do it like this because for some reason apk won't take a joined string directly
    let joined = $args | str join " "
    write debug $"($description): ($joined)." $script
    let result = do { ^sh -c $"apk ($cmd) ($joined)" }  | complete

    # exit on error
    if $result.exit_code > 0 {
        $result.stderr | print
        write error --code $result.exit_code $"Error ($description | str downcase) packages." $script
    }
}

# Use apk to install a list of packages
export def install [
    args: list<string>  # List of packages to add / arguments
] {
    action "install" "Installing" $args "add --no-cache"
}

# Use apk to remove a list of packages
export def remove [
    args: list<string>  # List of packages to delete / arguments
] {
    action "remove" "Removing" $args "del"
}

# Use apk to upgrade a list of packages
export def upgrade [
    args: list<string> = []  # List of packages to upgrade / arguments
] {
    action "upgrade" "Upgrading" $args "upgrade --no-cache"
}