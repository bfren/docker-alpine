import { esh } from "../bf/esh.js";
import { makeTempDir } from "../bf/fs.js";
import { handle } from "../bf/handle.js";
import * as sys from "../bf/sys.js";
import * as _ from "../bf/util.js";
import { runScript } from "./lib/capture.js";
const { assert } = sys;
const FILES = "/etc/tjs/scripts/tests/files";
//======================================================================================================================
// main
//======================================================================================================================
export async function main__outputs_correct_values() {
    // the template reads variables with bf-env in a child process, so esh runs in a child with them in its environment
    const $vars = { BF_YES: "yes", BF_NO: "no", BF_TRUE: "1", BF_FALSE: "0", PATH: sys.env.PATH };
    const $output = await runScript(`import * as bf from "bf";\nconsole.log(await bf.esh("${FILES}/template.esh"));\n`, $vars);
    const $file = `${await makeTempDir()}/output`;
    await sys.writeTextFile($file, $output);
    const $result = (await handle(["sha256sum", $file]) ?? "").split(" ")[0];
    assert.equal($result, "a81db67145fc91a2e07ab8f2d1062016f634aa2bf11d74af11709f9741c62be6");
}
//======================================================================================================================
// quoting
//======================================================================================================================
const QUOTES = `${FILES}/quotes.esh`;
// esh line 109: apostrophes in literal template text
export async function main__preserves_apostrophes_in_text() {
    const $result = _.splitLines(await esh(QUOTES));
    assert.equal($result[0], "literal: 'quoted' word");
    assert.equal($result[1], "literal-start: 'quoted at start' and end'");
    assert.equal($result[2], "literal-double: it''s two");
    assert.equal($result[3], "literal-backslash: C:\\path\\to it's");
}
// esh line 376: apostrophes in variables passed as arguments
export async function main__preserves_apostrophes_in_variables() {
    const $result = _.splitLines(await handle(["esh", QUOTES, "QUOTE=it's 'quoted'"]) ?? "");
    assert.equal($result[4], "variable: it's 'quoted'");
}
