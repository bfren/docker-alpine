import { handle } from "../bf/handle.js";
import * as sys from "../bf/sys.js";
import { randomChars, runScript } from "./lib/capture.js";
const { assert } = sys;
// x passes output straight through, so it runs in a child process whose stdout can be captured
const X = (path) => `import * as bf from "bf";\nawait bf.x("${path}");\n`;
/** Write a script that prints BF_X to path. */
function printBfX(path) {
    return sys.writeTextFile(path, `import * as bf from "bf";\nconsole.log(bf.sys.env.BF_X);\n`);
}
//======================================================================================================================
// main
//======================================================================================================================
export async function main__short_path__sets_bf_x_to_path() {
    const $path = `/tmp/${randomChars().slice(0, 6)}.js`;
    await printBfX($path);
    const $result = await runScript(X($path), { PATH: sys.env.PATH });
    await sys.remove($path);
    assert.equal($result, $path);
}
export async function main__long_path__sets_bf_x_to_filename() {
    const $dir = await handle(["mktemp", "-d"]) ?? "";
    const $path = `${$dir}/${randomChars()}.js`;
    await printBfX($path);
    const $result = await runScript(X($path), { PATH: sys.env.PATH });
    assert.equal($result, sys.path.basename($path));
}
export async function main__script_fails__throws_error() {
    const $dir = await handle(["mktemp", "-d"]) ?? "";
    const $path = `${$dir}/fail.js`;
    await sys.writeTextFile($path, `import * as bf from "bf";\nbf.sys.exit(3);\n`);
    const $result = await runScript(X($path), { PATH: sys.env.PATH }).then(() => "no error", () => "error");
    assert.equal($result, "error");
}
