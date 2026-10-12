use std/assert
use ../bf/pkg.nu *


#======================================================================================================================
# install
#======================================================================================================================

export def install__package_does_not_exist__returns_error [] {
    let name = $"does-not-exist-(random chars --length 12 | str downcase)"

    assert error {|| install [$name] }
}


#======================================================================================================================
# remove
#======================================================================================================================

export def remove__package_is_not_installed__returns_error [] {
    let name = $"does-not-exist-(random chars --length 12 | str downcase)"

    assert error {|| remove [$name] }
}
