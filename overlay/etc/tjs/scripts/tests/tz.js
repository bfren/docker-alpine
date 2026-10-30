import { pathInfo } from "../bf/fs.js";
import { handle } from "../bf/handle.js";
import * as sys from "../bf/sys.js";
import { current } from "../bf/tz.js";
import { runScript } from "./lib/capture.js";
const { assert } = sys;
//======================================================================================================================
// current
//======================================================================================================================
export async function current__returns_contents_of_timezone_file() {
    const $result = await current();
    const $expected = (await sys.readTextFile("/etc/timezone")).trim();
    assert.ok($result != "", "current returns an empty timezone");
    assert.equal($result.trim(), $expected);
}
//======================================================================================================================
// clean
//======================================================================================================================
/**
 * Run tz.clean against a temporary timezone definitions directory, with a stub apk (first on PATH, in a child process)
 * that reports whether tzdata is installed - returns the number of definitions left, or undefined if this is not
 * Alpine (Debian has no tz.clean).
 */
async function runClean(tzdataInstalled) {
    if (!(await pathInfo("/etc/alpine-release")).exists)
        return undefined;
    const $root = await handle(["mktemp", "-d"]) ?? "";
    await handle(["mkdir", "-p", `${$root}/bin`, `${$root}/zoneinfo/Europe`]);
    await sys.writeTextFile(`${$root}/zoneinfo/Europe/London`, "london");
    await sys.writeTextFile(`${$root}/bin/apk`, `#!/bin/sh\n[ "$1" = info ] && exit ${tzdataInstalled ? 0 : 1}\nexit 0\n`);
    await handle(["chmod", "+x", `${$root}/bin/apk`]);
    await runScript(`import * as bf from "bf";\nawait bf.tz.clean({ dir: "${$root}/zoneinfo" });\n`, { PATH: `${$root}/bin:${sys.env.PATH}` });
    const $left = await handle(["sh", "-c", `find ${$root}/zoneinfo -type f | wc -l`]) ?? "";
    await sys.remove($root);
    return parseInt($left);
}
export async function clean__tzdata_installed__keeps_definitions() {
    const $left = await runClean(true);
    if ($left === undefined)
        return;
    assert.equal($left, 1, "timezone definitions should be kept when tzdata is installed");
}
export async function clean__tzdata_not_installed__removes_definitions() {
    const $left = await runClean(false);
    if ($left === undefined)
        return;
    assert.equal($left, 0, "timezone definitions should be removed when tzdata is not installed");
}
