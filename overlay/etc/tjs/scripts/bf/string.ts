import * as write from "./write.ts";

/**
 * Add double quotes to input and return.
 *
 * @param input String to quote.
 * @returns Quoted string.
 */
export function quote(input: string): string {
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
export function format(input: string, values: Record<string, string>): string {
    // return an error if input contains placeholders that are not in values - checked before replacing, so values can
    // contain braces
    const $keys = new Set([...input.matchAll(/\{([^{}\s]+)\}/g)].map(($m) => $m[1]));
    const $unmatched = [...$keys].filter(($k) => !Object.hasOwn(values, $k));
    if ($unmatched.length > 0) {
        write.error("", "%s contains unmatched placeholders: %s.", input, $unmatched.map(($k) => `{${$k}}`).join(", "));
    }

    // replace values
    write.debug("str/format", "Using %o to replace placeholders in %s.", values, input);
    return Object.entries(values).reduce(($acc, [$k, $v]) => $acc.replaceAll(`{${$k}}`, $v), input);
}
