use write.nu

# Add double quotes to the input string and return.
export def quote []: string -> string { $"\"($in)\"" }

# Format a string by using $values to replace placeholders with values within $input:
#   - if $values = {a: "one" b: "two"}
#   - and $input = "this contains {a} and {b}"
#   - the result will be "this contains one and two"
#   - placeholders can be used multiple times
# There will be an error if there are any unmatched placeholders, or braces that are not part of a placeholder.
export def format [
    input: string   # String to format - placeholders should be record keys surrounded by braces, e.g. {a}
    values: record  # Values to use when replacing placeholders
]: nothing -> string {
    # format pattern replaces every placeholder in one pass, so values can contain braces
    try {
        $values | format pattern $input
    } catch {|e|
        write error $"Unable to format ($input): ($e.msg)." str/format
    }
}
