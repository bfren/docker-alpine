import { install, remove } from "../bf/pkg.ts";
import * as sys from "../bf/sys.ts";
import { randomChars } from "./lib/capture.ts";

const { assert } = sys;

/** Returns "error" if fn rejects, otherwise "no error". */
function outcome(fn: () => Promise<void>): Promise<string> {
    return fn().then(() => "no error", () => "error");
}


//======================================================================================================================
// install
//======================================================================================================================

export async function install__package_does_not_exist__returns_error() {
    const $name = `does-not-exist-${randomChars()}`;

    assert.equal(await outcome(() => install([$name])), "error");
}


//======================================================================================================================
// remove
//======================================================================================================================

export async function remove__package_is_not_installed__returns_error() {
    const $name = `does-not-exist-${randomChars()}`;

    assert.equal(await outcome(() => remove([$name])), "error");
}
