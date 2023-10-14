use print.nu

# Remove all files and directories matching glob
export def rmrf [
    glob: string    # Glob to match
] {
    print debug $"Force deleting files and directories matching ($glob)."
    glob $glob | each { rm -rf $in }
}