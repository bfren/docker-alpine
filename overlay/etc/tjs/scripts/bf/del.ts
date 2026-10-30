import * as fs from "./fs.ts";
import * as sys from "./sys.ts";
import * as write from "./write.ts";

/**
 * Options for old() function.
 */
export interface OldOptions {
    /** If not set, the paths to be deleted will be returned but not actually deleted. */
    live?: boolean;
    /** The type of path to delete, either 'd' (directory) or 'f' (file). */
    type?: string;
}

/**
 * Delete files or directories within rootDir older than duration.
 *
 * @param rootDir The root directory - files / directories directly within this will be deleted.
 * @param duration If a file or directory is older than this (in milliseconds) it will be deleted.
 * @param options Function options.
 * @returns The paths that are (or would be, if live is not set) deleted.
 */
export async function old(rootDir: string, duration: number, options: OldOptions = {}): Promise<string[]> {
    // throw an error if root directory does not exist
    if (await fs.isNotDir(rootDir)) write.error("del/old", "Directory %s does not exist.", rootDir);

    // ensure only valid types are used
    const $isType = ({
        d: ($i: fs.PathInfo) => $i.isDirectory,
        f: ($i: fs.PathInfo) => $i.isFile,
    } as Record<string, (i: fs.PathInfo) => boolean>)[options.type ?? ""];
    if (!$isType) write.error("del/old", "Unknown type: %s.", options.type);

    // find paths of type modified before expiry
    const $expiry = new Date(Date.now() - duration);
    const $root = rootDir.replace(/\/+$/, "");
    write.debug("del/old", "Removing %ss older than %s.", options.type == "d" ? "dir" : "file", $expiry.toISOString());

    const $old: string[] = [];
    for (const $name of await sys.readDir($root)) {
        const $info = await fs.pathInfo(`${$root}/${$name}`, { followSymlinks: false });
        if ($isType($info) && $info.stat!.mtim < $expiry) $old.push(`${$root}/${$name}`);
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
