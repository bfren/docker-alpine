/**
 * Compare two strings naturally (like Nushell's `sort --natural`), so runs of digits compare as numbers -
 * e.g. "1.2.10" sorts after "1.2.5". localeCompare's numeric option is not supported by txiki.js (no Intl).
 *
 * @param a First string.
 * @param b Second string.
 * @returns Negative if a sorts first, positive if b sorts first, 0 if they are equal.
 */
export function naturalCompare(a, b) {
    const $a = a.match(/\d+|\D+/g) ?? [], $b = b.match(/\d+|\D+/g) ?? [];
    for (let $i = 0; $i < Math.min($a.length, $b.length); $i++) {
        const [$x, $y] = [$a[$i], $b[$i]];
        const $cmp = /^\d/.test($x) && /^\d/.test($y) ? Number($x) - Number($y) : ($x < $y ? -1 : $x > $y ? 1 : 0);
        if ($cmp != 0)
            return $cmp;
    }
    return $a.length - $b.length;
}
