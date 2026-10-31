use dump.nu
use write.nu

# Add double quotes to the input string and return.
export def quote []: string -> string { $"\"($in)\"" }

# Format a string by using $values to replace placeholders with values within $input:
#   - if $values = {a: "one" b: "two"}
#   - and $input = "this contains {a} and {b}"
#   - the result will be "this contains one and two"
#   - placeholders can be used multiple times
# There will be an error if there are any unmatched placeholders.
export def format [
    input: string   # String to format - placeholds should be record keys surrounded by braces, e.g. {a}
    values: record  # Values to use when replacing placeholders
]: nothing -> string {
    # return an error if $input contains placeholders that are not in $values - checked before replacing, so values
    # can contain braces
    let unmatched = $input
        | parse --regex '\{(?<k>[^{}\s]+)\}'
        | get k
        | uniq
        | where $it not-in ($values | columns)
    if ($unmatched | is-not-empty) {
        write error $"($input) contains unmatched placeholders: ($unmatched | each { $'{($in)}' } | str join ', ')."
    }

    # replace values
    write debug $"Using ($values) to replace placeholders in ($input)." str/format
    let result = $values
        | transpose k v
        | reduce -f $input {|x, acc| $acc | str replace --all $"{($x.k)}" $x.v }

    # return formatted string
    $result
}
