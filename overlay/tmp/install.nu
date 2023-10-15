use ../usr/lib/bf/

let ns = $env.CURRENT_FILE

def main [] {
    # upgrade to current versions of binaries
    if (bf env check "BF_UPGRADE_PACKAGES") {
        bf print "Upgrading binaries..." $ns
        apk upgrade --no-cache
        bf print ok_done $ns
    }

    # get esh version and install
    cd /tmp
    try {
        let esh_version = cat ESH_BUILD
        bf print $"Installing esh v($esh_version)." $ns
        apk add --no-cache $"esh=($esh_version)"
        bf print ok_done $ns
    } catch {
        bf print notok_error "esh not installed." $ns
    }

    # install additional packages
    bf print "Installing additional packages." $ns
    try {
        apk add --no-cache figlet
        bf print ok_done $ns
    } catch {
        bf print notok_error "Unable to install additional packages." $ns
    }

    # set timezone
    bf tz "Europe/London"
}
