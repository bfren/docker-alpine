/**
 * Format a date in a consistent and sortable manner.
 *
 * @param date Date to use - defaults to 'now'.
 * @returns Formatted date - 'YearMonthDay HourMinute'.
 */
export function fmt(date?: Date): string {
    // if not set use now
    const $dt = date ?? new Date();

    // get date components
    const $year = $dt.getFullYear();
    const $month = pad($dt.getMonth());
    const $day = pad($dt.getDay());
    const $hour = pad($dt.getHours());
    const $minute = pad($dt.getMinutes());

    // return 'ymd HM' so it is sortable
    return `${$year}${$month}${$day} ${$hour}${$minute}`;
}

/**
 * Ensure single-digit numbers begin with a '0'.
 *
 * @param num The number to pad.
 * @returns Padded string.
 */
function pad(num: number): string {
    return new String(num).padStart(2, "0");
}