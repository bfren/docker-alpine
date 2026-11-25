use handle.nu
use write.nu

# Package manager cache directories, deleted by clean
export const caches = ["/var/cache/apk/*"]

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
    let on_failure = {|code, err|
        write error $"Error ($code) ($description | str lowercase) packages: ($joined).\n($err)" $script
    }
    { ^apk $cmd --no-cache ...$args } | handle -d $"($description) packages" -f $on_failure $script

    return
}

# Use apk to install a list of packages
#
# With --fallback-revision, a package pinned to an exact Alpine build (e.g. 'nginx=1.28.3-r9') that is missing from
# this architecture's repository is installed as the newest build of the same version instead ('nginx~1.28.3'), so
# an architecture whose repository has not caught up yet does not stop the build. A warning says what was installed.
export def install [
    args: list<string>          # List of packages to add / arguments
    --fallback-revision (-r)    # Fall back to another build of the same version if the pinned build is missing
]: nothing -> nothing {
    let resolved = if $fallback_revision {
        $args | each {|x|
            let pin = parse_pin $x
            if ($pin | is-empty) { $x } else { resolve_revision $x (available $pin.name) }
        }
    } else {
        $args
    }

    action "install" "Installing" "add" $resolved
}

# Return the version of an installed package, e.g. '1.28.3-r9' for 'nginx'
export def installed [
    name: string    # Package name
]: nothing -> string {
    { ^apk info -e -v $name } | handle -d $"Getting installed version of ($name)" "pkg/installed"
        | str replace $"($name)-" ""
}

# Return the versions of a package in the repository index, e.g. ['1.28.3-r7']
def available [
    name: string    # Package name
]: nothing -> list<string> {
    # 'apk policy' lists each available version on its own line, indented by two spaces and followed by ':'
    { ^apk --no-cache policy $name } | handle -d $"Getting available versions of ($name)" "pkg/available"
        | lines
        | parse --regex '^  (?<version>\S+):$'
        | get version
        | uniq
}

# Split an argument that pins an exact Alpine build (e.g. 'nginx=1.28.3-r9') into its parts, or return null
def parse_pin [
    arg: string     # Argument to apk add
]: nothing -> any {
    $arg | parse --regex '^(?<name>[^=~<>]+)=(?<version>.+)-r(?<build>\d+)$' | get --optional 0
}

# Return the argument to apk add for a package pinned to an exact build, given the versions available
export def resolve_revision [
    arg: string                 # Argument to apk add, e.g. 'nginx=1.28.3-r9'
    available: list<string>     # Versions available in the repository index, e.g. ['1.28.3-r7']
]: nothing -> string {
    let pin = parse_pin $arg
    if ($pin | is-empty) { return $arg }

    # keep the pin if its build is available - or if no build of the same version is, so apk reports it missing
    let wanted = $"($pin.version)-r($pin.build)"
    let same_version = $available | where {|x| ($x | str replace --regex '-r\d+$' '') == $pin.version }
    if ($wanted in $available) or ($same_version | is-empty) { return $arg }

    let fallback = $"($pin.name)~($pin.version)"
    let others = $same_version | str join ", "
    write warn $"($pin.name) ($wanted) is not available for this architecture - installing ($fallback) instead \(available: ($others))." "pkg/install"
    $fallback
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
