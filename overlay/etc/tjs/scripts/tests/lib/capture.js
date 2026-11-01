import { handle } from "../../bf/handle.js";
import * as sys from "../../bf/sys.js";
/**
 * Generate a random string (like Nushell's `random chars`).
 */
export function randomChars() {
    return Math.random().toString(36).slice(2);
}
/**
 * Run fn with vars set in the environment (undefined removes a variable), then restore them.
 * fn must be synchronous so no other (parallel) test can run while the environment is changed.
 *
 * @param vars Environment variables to set while fn runs.
 * @param fn Function to run.
 * @returns The result of fn.
 */
export function withEnv(vars, fn) {
    const $saved = Object.keys(vars).map(($k) => [$k, sys.env[$k]]);
    const set = ($k, $v) => { if ($v === undefined)
        delete sys.env[$k];
    else
        sys.env[$k] = $v; };
    for (const [$k, $v] of Object.entries(vars))
        set($k, $v);
    try {
        return fn();
    }
    finally {
        for (const [$k, $v] of $saved)
            set($k, $v);
    }
}
/**
 * Run fn with console output captured and vars set in the environment, then restore both.
 * fn must be synchronous so no other (parallel) test can run while console and environment are replaced.
 *
 * @param fn Function to run.
 * @param vars Environment variables to set while fn runs.
 * @param raw If set, ANSI codes will not be stripped.
 * @returns Captured stdout / stderr, and any error thrown by fn.
 */
export function capture(fn, vars = {}, raw = false) {
    const $out = [], $err = [];
    const [$log, $error] = [console.log, console.error];
    console.log = (...args) => { $out.push(args.join(" ")); };
    console.error = (...args) => { $err.push(args.join(" ")); };
    let $thrown;
    try {
        withEnv(vars, fn);
    }
    catch ($e) {
        $thrown = $e;
    }
    finally {
        [console.log, console.error] = [$log, $error];
    }
    const $strip = (s) => raw ? s.join("\n") : s.join("\n").replace(/\x1b\[[0-9;]*m/g, "");
    return { stdout: $strip($out), stderr: $strip($err), error: $thrown };
}
/**
 * Run code as a script in a child tjs process, with only vars in its environment - for tests that read or write the
 * whole environment, which would otherwise race with tests running in parallel in this process.
 *
 * @param code Script code - `bf` can be imported.
 * @param vars The child's entire environment.
 * @param name Script file name.
 * @returns Trimmed stdout (throws if the script fails).
 */
export async function runScript(code, vars = {}, name = `${randomChars()}.js`) {
    const $dir = await handle(["mktemp", "-d"]) ?? "";
    try {
        await sys.writeTextFile(`${$dir}/${name}`, code);
        const $vars = Object.entries(vars).map(([$k, $v]) => `${$k}=${$v}`);
        return await handle(["env", "-i", ...$vars, "tjs", "run", "--import-map", "/etc/tjs/map.json", `${$dir}/${name}`]) ?? "";
    }
    finally {
        await handle(["rm", "-rf", $dir]);
    }
}
