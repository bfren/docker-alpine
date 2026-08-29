/**
 * Turn a list of simple records into a Markdown table.
 *
 * @param data Records to convert to a Markdown table.
 * @returns String representation of a list of records.
 */
export function toTable(data) {
    // calculate the maximum length of keys and values to pad table nicely
    var $max_key_length = 0;
    Object.keys(data).map(k => $max_key_length = k.length > $max_key_length ? k.length : $max_key_length);
    var $max_val_length = 0;
    Object.values(data).map(v => $max_val_length = v.length > $max_val_length ? v.length : $max_val_length);
    // create markdown-compatible table rows
    const $rows = Object.keys(data).map(key => {
        const $k = escapeAndPad(key, $max_key_length);
        const $v = escapeAndPad(data[key], $max_val_length);
        return `| ${$k} | ${$v} |`;
    });
    return $rows.join("\n");
}
/**
 * Escape Markdown table values and pad with spaces to a fixed length.
 *
 * @param val String value to escape and pad.
 * @param length Length of string.
 * @returns String with Markdown table incompatible strings escaped, and padded to a fixed length.
 */
function escapeAndPad(val, length) {
    return val.padEnd(length, " ").replace(/\|/g, '\\|').replace(/\n/g, ' ');
}
