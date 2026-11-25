use std/assert
use ../bf/pkg.nu *

# installed and resolve_revision are Alpine only - Debian replaces pkg.nu with its own, which uses apt
def on_alpine []: nothing -> bool { "/etc/alpine-release" | path exists }


#======================================================================================================================
# install
#======================================================================================================================

export def install__package_does_not_exist__returns_error [] {
    let name = $"does-not-exist-(random chars --length 12 | str lowercase)"

    assert error {|| install [$name] }
}


#======================================================================================================================
# installed
#======================================================================================================================

export def installed__package_is_installed__returns_version [] {
    if not (on_alpine) { return }
    let result = installed "apk-tools"

    assert ($result =~ '^\d[^ ]*-r\d+$') $"'($result)' is not a package version"
}

export def installed__package_is_not_installed__returns_error [] {
    if not (on_alpine) { return }
    let name = $"does-not-exist-(random chars --length 12 | str lowercase)"

    assert error {|| installed $name }
}


#======================================================================================================================
# resolve_revision
#======================================================================================================================

export def resolve_revision__pinned_build_is_available__keeps_pin [] {
    if not (on_alpine) { return }
    let result = resolve_revision "nginx=1.28.3-r9" ["1.28.3-r9" "1.28.3-r7"]

    assert equal "nginx=1.28.3-r9" $result
}

export def resolve_revision__pinned_build_is_missing__falls_back_to_same_version [] {
    if not (on_alpine) { return }
    let result = resolve_revision "nginx=1.28.3-r9" ["1.28.3-r7"]

    assert equal "nginx~1.28.3" $result
}

export def resolve_revision__only_a_newer_build_is_available__falls_back_to_same_version [] {
    if not (on_alpine) { return }
    let result = resolve_revision "nginx=1.28.3-r9" ["1.28.3-r10"]

    assert equal "nginx~1.28.3" $result
}

export def resolve_revision__no_build_of_the_same_version__keeps_pin [] {
    if not (on_alpine) { return }
    # 1.28.30 and 1.28.4 are different versions, so apk should report the pinned build as missing
    let result = resolve_revision "nginx=1.28.3-r9" ["1.28.30-r0" "1.28.4-r0"]

    assert equal "nginx=1.28.3-r9" $result
}

export def resolve_revision__nothing_is_available__keeps_pin [] {
    if not (on_alpine) { return }
    let result = resolve_revision "nginx=1.28.3-r9" []

    assert equal "nginx=1.28.3-r9" $result
}

export def resolve_revision__argument_is_not_pinned_to_a_build__is_unchanged [] {
    if not (on_alpine) { return }
    for arg in ["nginx" "nginx~1.28.3" "nginx=1.28.3" "nginx>1.28" "--no-scripts"] {
        assert equal $arg (resolve_revision $arg ["1.28.3-r7"])
    }
}

export def resolve_revision__name_contains_hyphens__falls_back_to_same_version [] {
    if not (on_alpine) { return }
    let result = resolve_revision "nginx-mod-http-brotli=1.28.3-r9" ["1.28.3-r7"]

    assert equal "nginx-mod-http-brotli~1.28.3" $result
}


#======================================================================================================================
# remove
#======================================================================================================================

export def remove__package_is_not_installed__returns_error [] {
    let name = $"does-not-exist-(random chars --length 12 | str lowercase)"

    assert error {|| remove [$name] }
}
