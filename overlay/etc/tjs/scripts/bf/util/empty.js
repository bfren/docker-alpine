/**
 * Returns true if val is null / undefined / "" / 0 / false.
 *
 * @param val Value to test.
 * @returns Whether or not val is an 'empty' value.
 */
export function empty(val) {
    return val == null || val == undefined || val == "" || val == 0 || !val;
}
/**
 * Returns true if val is not null / undefined / "" / 0 / false.
 *
 * @param val Value to test.
 * @returns Whether or not val is not an 'empty' value.
 */
export function not_empty(val) {
    return !empty(val);
}
