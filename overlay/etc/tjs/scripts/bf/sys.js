/**
 * The only module that talks to the txiki.js runtime - everything else (including downstream images) must use
 * these wrappers instead of tjs.* or tjs:* directly, so moving to another runtime means rewriting this file only.
 */
import assert from "tjs:assert";
import path from "tjs:path";
export { assert, path };
/** Runtime version. */
export const version = tjs.version;
// index of the script path in tjs.args - after 'tjs run' and any run options
// shortcut: assumes every run option takes a value (true of --import-map, the only one tjsh uses), revisit if tjsh adds a flag
const SCRIPT_INDEX = (() => {
    let $i = 2;
    while (tjs.args[$i]?.startsWith("-"))
        $i += 2;
    return $i;
})();
/** Path of the running script (undefined if there isn't one, e.g. in eval). */
export const script = tjs.args[SCRIPT_INDEX];
/** Script arguments - tjs.args without 'tjs run', run options or the script path. */
export const args = tjs.args.slice(SCRIPT_INDEX + 1);
/**
 * Write text to stdout without a trailing newline.
 *
 * @param text Text to write.
 */
export async function print(text) {
    const $writer = tjs.stdout.getWriter();
    try {
        await $writer.write(new TextEncoder().encode(text));
    }
    finally {
        $writer.releaseLock();
    }
}
/**
 * Exit the process.
 *
 * @param code Exit code.
 */
export function exit(code) {
    return tjs.exit(code);
}
/** System environment variables (read / write). */
export const env = tjs.env;
/**
 * Run an executable, capturing stderr and stdout.
 *
 * @param args The executable followed by its arguments.
 * @returns Exit status, stderr and stdout.
 */
export async function spawn(args) {
    const $p = tjs.spawn(args, { stderr: "pipe", stdout: "pipe" });
    const [$stderr, $stdout, $result] = await Promise.all([
        new Response($p.stderr).text(),
        new Response($p.stdout).text(),
        $p.wait()
    ]);
    return { status: $result.exit_status, stderr: $stderr, stdout: $stdout };
}
/**
 * Resolve path to an absolute path, following symlinks.
 *
 * @param path Absolute or relative path.
 * @returns Absolute path.
 */
export function realPath(path) {
    return tjs.realPath(path);
}
/**
 * Get file information, following symlinks.
 *
 * @param path Absolute or relative path.
 */
export function stat(path) {
    return tjs.stat(path);
}
/**
 * Get file information, without following symlinks.
 *
 * @param path Absolute or relative path.
 */
export function lstat(path) {
    return tjs.lstat(path);
}
/**
 * Read a file as UTF-8 text.
 *
 * @param path File path.
 * @returns File contents.
 */
export async function readTextFile(path) {
    return new TextDecoder().decode(await tjs.readFile(path));
}
/**
 * Write UTF-8 text to a file, replacing any existing contents.
 *
 * @param path File path.
 * @param data Text to write.
 */
export function writeTextFile(path, data) {
    return tjs.writeFile(path, data);
}
/**
 * List the names of the entries in a directory.
 *
 * @param path Directory path.
 * @returns Entry names (not full paths).
 */
export async function readDir(path) {
    const $names = [];
    for await (const $entry of await tjs.readDir(path))
        $names.push($entry.name);
    return $names;
}
/**
 * Remove a file or directory.
 *
 * @param path File or directory path.
 */
export function remove(path) {
    return tjs.remove(path);
}
/**
 * Rename (move) a file or directory.
 *
 * @param from Current path.
 * @param to New path.
 */
export function rename(from, to) {
    return tjs.rename(from, to);
}
