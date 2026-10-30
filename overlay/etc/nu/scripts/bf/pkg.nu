use dump.nu
use handle.nu
use write.nu

# Perform a package action, capturing result and outputting any errors
def action [
    name: string        # Name of the action
    description: string # Description of the action for logs
    cmd: string         # The actual command to run
    args: list<string>  # Command arguments
]: nothing -> nothing {
    # add pkg to the script name
    let script = $"pkg/($name)"

    # use shell to run apk
    let joined = $args | str join " "
    write debug $"($description): ($joined)." $script
    let on_failure = {|code, err| write error $"Error ($code) ($description | str downcase) packages: ($joined).\n($err)" $script }
    { ^apk $cmd --no-cache ...$args } | handle -d $"($description) packages" -f $on_failure $script

    return
}

# Use apk to install a list of packages
export def install [
    args: list<string>  # List of packages to add / arguments
]: nothing -> nothing {
    action "install" "Installing" "add" $args
}

# Use apk to remove a list of packages
export def remove [
    args: list<string>  # List of packages to delete / arguments
]: nothing -> nothing {
    action "remove" "Removing" "del" $args
}

# Use apk to upgrade a list of packages
export def upgrade [
    args: list<string> = []  # List of packages to upgrade / arguments
]: nothing -> nothing {
    action "upgrade" "Upgrading" "upgrade" $args
}
