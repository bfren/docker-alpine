import { BUILD_FILE } from "../bf/build.js";
import { makeTempDir } from "../bf/fs.js";
import * as sys from "../bf/sys.js";
import { randomChars, runScript } from "./lib/capture.js";
const { assert } = sys;
// build reads BF_ETC after awaiting, so each test runs in a child process with its own BF_ETC
//======================================================================================================================
// main (get)
//======================================================================================================================
export async function main__parses_build_log() {
    const [$k, $v] = [randomChars(), randomChars()];
    const $etc = await makeTempDir();
    await sys.writeTextFile(`${$etc}/${BUILD_FILE}`, `${$k}: ${$v}\n`);
    const $result = await runScript(`import * as bf from "bf";\nconsole.log((await bf.build.get())["${$k}"]);\n`, { BF_ETC: $etc });
    assert.equal($result, $v, "incorrect value found");
}
//======================================================================================================================
// add
//======================================================================================================================
export async function add__appends_key_and_value() {
    const [$k, $v] = [randomChars(), randomChars()];
    const $etc = await makeTempDir();
    await runScript(`import * as bf from "bf";\nawait bf.build.add("${$k}", "${$v}");\n`, { BF_ETC: $etc });
    const $result = (await sys.readTextFile(`${$etc}/${BUILD_FILE}`)).trim();
    assert.equal($result, `${$k}: ${$v}`, "build log entry not saved correctly");
}
