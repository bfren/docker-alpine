use ../usr/lib/bf/

def main [] {
    # upgrade to current versions of binaries
    if (bf env check "BF_UPGRADE_PACKAGES") {
        bf print "Upgrading binaries..." "/tmp/install"
        apk upgrade --no-cache
        bf print ok_done "/tmp/install"
    }

    # get esh version and install
    cd /tmp
    try {
        let esh_version = cat ESH_BUILD
        bf print $"Installing esh v($esh_version)." "/tmp/install"
        apk add --no-cache $"esh=($esh_version)"
        bf print ok_done "/tmp/install"
    } catch {
        bf print notok_error "esh not installed." "/tmp/install"
    }

    # install additional packages
    bf print "Installing additional packages." "/tmp/install"
    try {
        apk add --no-cache figlet
        bf print ok_done "/tmp/install"
    } catch {
        bf print notok_error "Unable to install additional packages." "/tmp/install"
    }

    # set timezone
    bf tz "Europe/London"
}
