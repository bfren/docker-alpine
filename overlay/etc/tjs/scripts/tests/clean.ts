import { clean } from "../bf/clean.ts";
import { makeTempDir, pathInfo } from "../bf/fs.ts";
import { handle } from "../bf/handle.ts";
import * as sys from "../bf/sys.ts";
import { randomChars } from "./lib/capture.ts";

const { assert } = sys;


//======================================================================================================================
// main (clean)
//======================================================================================================================

/** Runs clean inside temporary directories, so tests never touch the rest of the filesystem. */
async function cleanE(options: { cache?: string, tmpdir?: string, sources?: string } = {}): Promise<void> {
    const $tmp = options.tmpdir ?? await makeTempDir();
    const $cache = options.cache ?? await makeTempDir();
    const $sources = options.sources ?? await makeTempDir();
    await clean({ caches: [`${$cache}/*`], tmpdirs: [`${$tmp}/*`], root: $tmp, sources: [$sources] });
}

/** Make a temporary file in dir. */
function mktemp(dir: string, directory = false): Promise<string | undefined> {
    return handle(["mktemp", ...(directory ? ["-d"] : []), "-p", dir]);
}

/** Returns true if path exists. */
async function exists(path: string): Promise<boolean> {
    return (await pathInfo(path, { followSymlinks: false })).exists;
}

export async function main__deletes_tmp() {
    const $tmpdir = await makeTempDir();
    await mktemp($tmpdir);
    await mktemp($tmpdir);
    const $before = (await sys.readDir($tmpdir)).length;

    await cleanE({ tmpdir: $tmpdir });

    assert.notEqual((await sys.readDir($tmpdir)).length, $before);
}

export async function main__deletes_cache() {
    const $cache = await makeTempDir();
    await mktemp($cache);
    await mktemp($cache);
    const $before = (await sys.readDir($cache)).length;

    await cleanE({ cache: $cache });

    assert.notEqual((await sys.readDir($cache)).length, $before);
}

export async function main__deletes_dot_empty_files() {
    const $tmpdir = await makeTempDir();
    const $file0 = `${await mktemp($tmpdir, true)}/.empty`;
    const $file1 = `${await mktemp($tmpdir, true)}/.empty`;
    await sys.writeTextFile($file0, randomChars());
    await sys.writeTextFile($file1, randomChars());

    await cleanE({ tmpdir: $tmpdir });

    assert.equal(await exists($file0) || await exists($file1), false);
}

export async function main__only_deletes_dot_empty_files_under_root() {
    const [$root, $other] = [await makeTempDir(), await makeTempDir()];
    const $inside = `${await mktemp($root, true)}/.empty`;
    const $outside = `${$other}/.empty`;
    await sys.writeTextFile($inside, "");
    await sys.writeTextFile($outside, "");

    await clean({ caches: [], tmpdirs: [], root: $root, sources: [] });

    assert.equal(await exists($inside), false);
    assert.equal(await exists($outside), true);
}

export async function main__deletes_typescript_sources() {
    const $sources = await makeTempDir();
    const $sub = await mktemp($sources, true);
    for (const $f of ["a.ts", "a.js"]) await sys.writeTextFile(`${$sources}/${$f}`, "");
    await sys.writeTextFile(`${$sub}/b.ts`, "");

    await cleanE({ sources: $sources });

    assert.deepEqual([await exists(`${$sources}/a.ts`), await exists(`${$sub}/b.ts`)], [false, false], "clean does not delete .ts files");
    assert.equal(await exists(`${$sources}/a.js`), true, "clean deletes .js files");
}
