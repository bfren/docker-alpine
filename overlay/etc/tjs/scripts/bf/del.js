import * as fs from "./fs.js";
import * as sys from "./sys.js";
import * as write from "./write.js";
/**
 * Delete files or directories within rootDir older than duration.
 *
 * @param rootDir The root directory - files / directories directly within this will be deleted.
 * @param duration If a file or directory is older than this (in milliseconds) it will be deleted.
 * @param options Function options.
 * @returns The paths that are (or would be, if live is not set) deleted.
 */
export async function old(rootDir, duration, options = {}) {
    // throw an error if root directory does not exist
    if (await fs.isNotDir(rootDir))
        write.error("del/old", "Directory %s does not exist.", rootDir);
    // ensure only valid types are used
    const $isType = {
        d: ($i) => $i.isDirectory,
        f: ($i) => $i.isFile,
    }[options.type ?? ""];
    if (!$isType)
        write.error("del/old", "Unknown type: %s.", options.type);
    // find paths of type modified before expiry
    const $expiry = new Date(Date.now() - duration);
    const $root = rootDir.replace(/\/+$/, "");
    write.debug("del/old", "Removing %ss older than %s.", options.type == "d" ? "dir" : "file", $expiry.toISOString());
    const $old = [];
    for (const $name of await sys.readDir($root)) {
        const $info = await fs.pathInfo(`${$root}/${$name}`, { followSymlinks: false });
        if ($isType($info) && $info.stat.mtim < $expiry)
            $old.push(`${$root}/${$name}`);
    }
    // perform deletion
    if (options.live) {
        for (const $path of $old) {
            write.debug("del/old", " .. %s", $path);
            await sys.remove($path);
        }
    }
    return $old;
}
