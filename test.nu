#!/usr/bin/env -S nu -n

use ../index/test.nu

const alpine_branches = [
    "3.20"
    "3.21"
    "3.22"
    "3.23"
    "3.24"
]

# Run test suite for image
def main [
    alpine: string = "3.24" # define which Alpine version to use
    --all (-a)              # test all registered versions of Alpine (overrides $alpine)
] {
    let branches = if $all { $alpine_branches } else { [$alpine] }
    test "alpine" $branches
}
