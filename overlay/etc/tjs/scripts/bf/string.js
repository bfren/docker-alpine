import * as write from "./write.js";
/**
 * Add double quotes to input and return.
 *
 * @param input String to quote.
 * @returns Quoted string.
 */
export function quote(input) {
    return `"${input}"`;
}
/**
 * Format a string by using values to replace placeholders within input:
 *   - if values = { a: "one", b: "two" }
 *   - and input = "this contains {a} and {b}"
 *   - the result will be "this contains one and two"
 *   - placeholders can be used multiple times
 * There will be an error if there are any unmatched placeholders.
 *
 * @param input String to format - placeholders should be keys surrounded by braces, e.g. {a}.
 * @param values Values to use when replacing placeholders.
 * @returns Formatted string.
 */
export function format(input, values) {
    // replace values
    write.debug("str/format", "Using %o to replace placeholders in %s.", values, input);
    const $result = Object.entries(values).reduce(($acc, [$k, $v]) => $acc.replaceAll(`{${$k}}`, $v), input);
    // return an error if the result still contains unmatched placeholders
    const $unmatched = $result.split(" ").filter(($x) => /\{.*\}/.test($x));
    if ($unmatched.length > 0)
        write.error("", "%s contains unmatched placeholders: %s.", input, $unmatched.join(", "));
    // return formatted string
    return $result;
}
