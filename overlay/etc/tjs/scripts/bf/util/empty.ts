/**
 * Returns true if val is null / undefined / "" / 0 / false.
 *
 * @param val Value to test.
 * @returns Whether or not val is an 'empty' value.
 */
export function empty<T>(val: T | null | undefined): val is (null | undefined) {
    return val === null || val === undefined || val === "" || val === 0 || val === false;
}

/**
 * Returns true if val is not null / undefined / "" / 0 / false.
 *
 * @param val Value to test.
 * @returns Whether or not val is not an 'empty' value.
 */
export function notEmpty<T>(val: T | null | undefined): val is T {
    return !empty(val);
}