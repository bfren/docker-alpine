use write.nu

# Format a string by using $values to replace placeholders with values within $input:
#   - if $values = {a: "one" b: "two"}
#   - and $input = "this contains {a} and {b}"
#   - the result will be "this contains one and two"
#   - placeholders can be used multiple times
# There will be an error if there are any unmatched placeholders.
export def format [
    values: record  # Values to use when replacing placeholders
    input: string   # String to format - placeholds should be record keys surrounded by braces, e.g. {a}
] {
    # replace values
    write debug $"Using ($values) to replace placeholders in ($input)." str/format
    let result = $values | transpose k v | reduce -f $input {|x, acc| $acc | str replace --all $"{($x.k)}" $x.v }

    # return an error if the result still contains unmatched palceholders
    if $result =~ "\{.*\}" { write error $"($input) contains unmatched palceholders." str/format }

    # return formatted string
    $result
}
