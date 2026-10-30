import { makeTempDir } from "../bf/fs.ts";
import { download, getStatus, test } from "../bf/http.ts";
import * as sys from "../bf/sys.ts";
import { randomChars, runScript } from "./lib/capture.ts";

const { assert } = sys;

const URL = "https://github.com/bfren/docker-alpine.git";

/** Returns the results of fn for each of from..to (inclusive), running 25 at a time. */
async function range<T>(from: number, to: number, fn: (x: number) => Promise<T>): Promise<T[]> {
    const $results: T[] = [];
    for (let $i = from; $i <= to; $i += 25) {
        const $batch = Array.from({ length: Math.min(25, to - $i + 1) }, (_, $j) => fn($i + $j));
        $results.push(...await Promise.all($batch));
    }
    return $results;
}


//======================================================================================================================
// download
//======================================================================================================================

export async function download__uses_filename_when_destination_is_not_specified() {
    // the working directory is shared by every test in this process, so change it in a child process
    const $dir = await makeTempDir();

    await runScript(`import * as bf from "bf";\nbf.sys.chdir("${$dir}");\nawait bf.http.download("${URL}");\n`);

    assert.equal((await sys.readDir($dir)).length, 1);
}

export async function download__saves_to_destination() {
    const $destination = `${await makeTempDir()}/${randomChars()}`;

    await download(URL, $destination);

    assert.equal((await sys.readDir(sys.path.dirname($destination))).includes(sys.path.basename($destination)), true);
}


//======================================================================================================================
// get_status
//======================================================================================================================

export async function get_status__returns_correct_status() {
    const $status = 200 + Math.floor(Math.random() * 301);

    const $result = await getStatus(`https://bfren.dev/status/${$status}`);

    assert.equal($result, $status, "get_status does not return correct status");
}

export async function get_status__invalid_url__returns_400() {
    const $result = await getStatus(randomChars());

    assert.equal($result, 400, "get_status does not return 400 for an invalid URL");
}


//======================================================================================================================
// test
//======================================================================================================================

export async function test__valid_status__returns_true() {
    const $result = await range(200, 399, ($x) => test(`https://bfren.dev/status/${$x}`));

    assert.equal($result.every(($x) => $x), true, "test does not return true for all valid statuses");
}

export async function test__invalid_status__returns_false() {
    const $result = await range(400, 599, ($x) => test(`https://bfren.dev/status/${$x}`));

    assert.equal($result.every(($x) => !$x), true, "test does not return false for all invalid statuses");
}
