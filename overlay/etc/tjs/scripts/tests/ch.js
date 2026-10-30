import { apply, applyRow } from "../bf/ch.js";
import { makeTempDir } from "../bf/fs.js";
import { handle } from "../bf/handle.js";
import * as sys from "../bf/sys.js";
import { randomChars } from "./lib/capture.js";
const { assert } = sys;
//======================================================================================================================
// helpers
//======================================================================================================================
/** Returns the octal mode of path. */
async function mode(path) {
    return await handle(["stat", "-c", "%a", path]) ?? "";
}
/** Returns the uid:gid of path. */
async function ids(path) {
    return await handle(["stat", "-c", "%u:%g", path]) ?? "";
}
/** Creates a directory (mode 700) containing a file (mode 600) and a sub-directory (mode 700). */
async function setup() {
    const $dir = await makeTempDir();
    const [$file, $sub] = [`${$dir}/file`, `${$dir}/sub`];
    await handle(["sh", "-c", `touch ${$file} && mkdir ${$sub} && chmod 600 ${$file} && chmod 700 ${$sub} ${$dir}`]);
    return { dir: $dir, file: $file, sub: $sub };
}
//======================================================================================================================
// main (apply)
//======================================================================================================================
export async function main__mode_sets_mode_on_path() {
    const $x = await setup();
    await apply([$x.file], { mode: "640" });
    assert.equal(await mode($x.file), "640");
}
export async function main__type_f_sets_mode_on_files_only() {
    const $x = await setup();
    await apply([$x.dir], { type: "f", mode: "644" });
    assert.equal(await mode($x.file), "644");
    assert.equal(await mode($x.sub), "700");
}
export async function main__type_d_sets_mode_on_directories_only() {
    const $x = await setup();
    await apply([$x.dir], { type: "d", mode: "755" });
    assert.equal(await mode($x.sub), "755");
    assert.equal(await mode($x.file), "600");
}
export async function main__recurse_sets_mode_on_everything() {
    const $x = await setup();
    await apply([$x.dir], { recurse: true, mode: "750" });
    assert.deepEqual([await mode($x.dir), await mode($x.sub), await mode($x.file)], ["750", "750", "750"]);
}
export async function main__owner_sets_ownership() {
    const $x = await setup();
    await apply([$x.file], { owner: "1234:1234" });
    assert.equal(await ids($x.file), "1234:1234");
}
export async function main__type_f_sets_ownership_on_files_only() {
    const $x = await setup();
    const $subIds = await ids($x.sub);
    await apply([$x.dir], { type: "f", owner: "1234:1234" });
    assert.equal(await ids($x.file), "1234:1234");
    assert.equal(await ids($x.sub), $subIds);
}
//======================================================================================================================
// apply (applyRow)
//======================================================================================================================
export async function apply__fewer_than_two_values__does_nothing() {
    const $x = await setup();
    await applyRow([$x.file]);
    assert.equal(await mode($x.file), "600");
}
export async function apply__owner_is_applied_recursively() {
    const $x = await setup();
    await applyRow([$x.dir, "1234:1234"]);
    assert.deepEqual([await ids($x.dir), await ids($x.sub), await ids($x.file)], ["1234:1234", "1234:1234", "1234:1234"]);
}
export async function apply__file_mode_is_applied_to_files_only() {
    const $x = await setup();
    await applyRow([$x.dir, "0:0", "644"]);
    assert.equal(await mode($x.file), "644");
    assert.equal(await mode($x.sub), "700");
}
export async function apply__directory_mode_is_applied_to_directories_only() {
    const $x = await setup();
    await applyRow([$x.dir, "0:0", "", "755"]);
    assert.equal(await mode($x.file), "600");
    assert.equal(await mode($x.sub), "755");
    assert.equal(await mode($x.dir), "755");
}
export async function apply__file_and_directory_modes_are_both_applied() {
    const $x = await setup();
    await applyRow([$x.dir, "0:0", "644", "755"]);
    assert.deepEqual([await mode($x.dir), await mode($x.sub), await mode($x.file)], ["755", "755", "644"]);
}
export async function apply__path_does_not_exist__does_not_error() {
    await applyRow([`/tmp/${randomChars()}`, "0:0", "644", "755"]);
}
