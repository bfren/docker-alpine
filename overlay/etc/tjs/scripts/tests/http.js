import { makeTempDir } from "../bf/fs.js";
import { download, getStatus, test } from "../bf/http.js";
import * as sys from "../bf/sys.js";
import { randomChars, runScript } from "./lib/capture.js";
const { assert } = sys;
const URL = "https://github.com/bfren/docker-alpine.git";
/** Returns the results of fn for each of from..to (inclusive), with up to 50 running at once - all at once is flaky. */
async function range(from, to, fn) {
    const $results = [];
    let $next = from;
    const worker = async () => { while ($next <= to) {
        const $x = $next++;
        $results[$x - from] = await fn($x);
    } };
    await Promise.all(Array.from({ length: 50 }, worker));
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
