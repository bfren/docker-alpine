import { old } from "../bf/del.js";
import { makeTempDir } from "../bf/fs.js";
import { handle } from "../bf/handle.js";
import * as sys from "../bf/sys.js";
import { randomChars } from "./lib/capture.js";
const { assert } = sys;
const DAY = 24 * 60 * 60 * 1000;
/** Returns the error message if fn rejects, otherwise "no error". */
function message(fn) {
    return fn().then(() => "no error", ($e) => $e.message);
}
/** Make a file in dir with its modified time set to time. */
async function fileAt(dir, time) {
    const $file = await handle(["mktemp", "-p", dir]) ?? "";
    await handle(["touch", "-d", `@${Math.floor(time / 1000)}`, $file]);
    return $file;
}
//======================================================================================================================
// old
//======================================================================================================================
export async function old__directory_does_not_exist_returns_error() {
    const $rootDir = `/tmp/${randomChars()}`;
    const $result = await message(() => old($rootDir, DAY, { type: "d" }));
    assert.equal($result, `Directory ${$rootDir} does not exist.`);
}
export async function old__unknown_type_returns_error() {
    const $type = randomChars();
    const $result = await message(async () => old(await makeTempDir(), DAY, { type: $type }));
    assert.equal($result, `Unknown type: ${$type}.`);
}
export async function old__live_not_set_returns_files_older_than_duration() {
    const $rootDir = await makeTempDir();
    const $duration = (5 + Math.floor(Math.random() * 6)) * DAY;
    const $older = await fileAt($rootDir, Date.now() - $duration - DAY);
    const $newer = await fileAt($rootDir, Date.now());
    const $result = await old($rootDir, $duration, { type: "f" });
    const $left = (await sys.readDir($rootDir)).map(($x) => `${$rootDir}/${$x}`).sort();
    assert.deepEqual($result, [$older], "old does not return the older file");
    assert.deepEqual($left, [$older, $newer].sort(), "old deletes files when live is not set");
}
export async function old__live_set_deletes_files_older_than_duration() {
    const $rootDir = await makeTempDir();
    const $duration = (5 + Math.floor(Math.random() * 6)) * DAY;
    await fileAt($rootDir, Date.now() - $duration - DAY);
    const $newer = await fileAt($rootDir, Date.now());
    await old($rootDir, $duration, { live: true, type: "f" });
    const $left = (await sys.readDir($rootDir)).map(($x) => `${$rootDir}/${$x}`);
    assert.deepEqual($left, [$newer]);
}
