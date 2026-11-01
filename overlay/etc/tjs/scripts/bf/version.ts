import * as _ from "./util.ts";

/**
 * Returns true if version is at least equal to minimum.
 *
 * @param version The version to check.
 * @param minimum The minimum version required.
 */
export function isAtLeast(version: string, minimum: string): boolean {
    // use natural comparison to ensure (e.g.) 1.2.10 comes above 1.2.5
    return _.naturalCompare(version, minimum) >= 0;
}

/**
 * Bump the patch number of the specified version (e.g. 1.2.10 -> 1.2.11).
 *
 * @param version The version to bump.
 * @returns Bumped version.
 */
export function bump(version: string): string {
    const [$major, $minor, $patch] = version.split(".");
    return `${$major}.${$minor}.${parseInt($patch) + 1}`;
}
