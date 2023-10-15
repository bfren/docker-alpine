use ../usr/lib/bf/

let ns = $env.CURRENT_FILE

def main [] {
    # upgrade to current versions of binaries
    if (bf env check "BF_UPGRADE_PACKAGES") {
        bf write "Upgrading binaries..." $ns
        apk upgrade --no-cache
        bf write ok_done $ns
    }

    # get esh version and install
    cd /tmp
    try {
        let esh_version = cat ESH_BUILD
        bf write $"Installing esh v($esh_version)." $ns
        apk add --no-cache $"esh=($esh_version)"
        bf write ok_done $ns
    } catch {
        bf write notok_error "esh not installed." $ns
    }

    # install additional packages
    bf write "Installing additional packages." $ns
    try {
        apk add --no-cache figlet
        bf write ok_done $ns
    } catch {
        bf write notok_error "Unable to install additional packages." $ns
    }

    # set timezone
    bf tz "Europe/London"
}
