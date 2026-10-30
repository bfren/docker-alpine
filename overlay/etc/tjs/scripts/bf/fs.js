import { handle } from "./handle.js";
import * as sys from "./sys.js";
import * as _ from "./util.js";
import * as write from "./write.js";
/**
 * Default options for pathInfo() function.
 */
const DEFAULT_PATHINFO_OPTIONS = {
    followSymlinks: true
};
/**
 * Get info relating to a path.
 *
 * @param path Absolute or relative path to a file / directory / symlink.
 * @param options Function options.
 * @returns PathInfo object.
 */
export async function pathInfo(path, options = {}) {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_PATHINFO_OPTIONS, ...options };
    // stat / lstat will fail if the file does not exist or is not readable / accessible
    try {
        const $st = await ($opt.followSymlinks ? sys.stat(path) : sys.lstat(path));
        return {
            path: $opt.followSymlinks ? await sys.realPath(path) : path,
            exists: true,
            isFile: $st.isFile,
            isDirectory: $st.isDirectory,
            isSymlink: $st.isSymbolicLink,
            stat: $st
        };
    }
    catch {
        return {
            path: path,
            exists: false,
            isFile: false,
            isDirectory: false,
            isSymlink: false
        };
    }
}
/**
 * Check type is valid (i.e. supported by posix find).
 *
 * @param type Type to check - directories (d), files (f) or symlinks (l).
 */
function checkType(type) {
    if (!["d", "f", "l"].includes(type))
        write.error("fs/check_type", "%s is not supported.", type);
}
/**
 * Use posix find to search basePath, returning matching paths - or an empty list if basePath does not exist or
 * find fails.
 *
 * @param basePath Base path to search.
 * @param args Arguments to add to find.
 * @param text Text to use when dumping a failed result.
 */
async function find(basePath, args, text) {
    if (!(await pathInfo(basePath)).exists)
        return [];
    return handle(["busybox", "find", basePath, "-xdev", ...args], {
        script: "fs/find",
        dumpResult: text,
        onFailure: () => [],
        onSuccess: ($out) => _.splitLines($out).filter(($x) => $x != "")
    });
}
/**
 * Find all paths called name in basePath.
 *
 * @param basePath Base path to search.
 * @param name Name to search for within basePath.
 * @param type Limit results to paths of this type - directories (d), files (f) or symlinks (l).
 * @returns Matching paths.
 */
export async function findName(basePath, name, type = "f") {
    checkType(type);
    return find(basePath, ["-name", name, "-type", type], `Find ${name} in ${basePath}.`);
}
/**
 * Find all paths that are type in basePath.
 *
 * @param basePath Base path to search.
 * @param type Limit results to paths of this type - directories (d), files (f) or symlinks (l).
 * @returns Matching paths.
 */
export async function findType(basePath, type) {
    checkType(type);
    return find(basePath, ["-type", type], `Find type ${type} in ${basePath}.`);
}
/**
 * Find all paths that are type in basePaths.
 *
 * @param basePaths Base paths to search.
 * @param type Limit results to paths of this type - directories (d), files (f) or symlinks (l).
 * @returns Matching paths from all basePaths.
 */
export async function findTypeAcc(basePaths, type) {
    return (await Promise.all(basePaths.map(($x) => findType($x, type)))).flat();
}
/**
 * Returns the type of path without following symlinks (like Nushell's `path type`): "dir", "file", "symlink", or
 * "" if it does not exist.
 *
 * @param path Path to check.
 */
async function pathType(path) {
    const $info = await pathInfo(path, { followSymlinks: false });
    return $info.isSymlink ? "symlink" : $info.isDirectory ? "dir" : $info.isFile ? "file" : "";
}
/**
 * Returns true if path exists and is a directory (not a symlink to one).
 *
 * @param path Path to check.
 */
export async function isDir(path) {
    return (await pathType(path)) == "dir";
}
/**
 * Returns true unless path exists and is a directory.
 *
 * @param path Path to check.
 */
export async function isNotDir(path) {
    return (await pathType(path)) != "dir";
}
/**
 * Returns true unless path exists and is a file.
 *
 * @param path Path to check.
 */
export async function isNotFile(path) {
    return (await pathType(path)) != "file";
}
/**
 * Returns true unless path exists and is a symlink.
 *
 * @param path Path to check.
 */
export async function isNotSymlink(path) {
    return (await pathType(path)) != "symlink";
}
/**
 * Make a temporary directory in /tmp.
 *
 * @param options Function options.
 * @returns Path to the new directory.
 */
export async function makeTempDir(options = {}) {
    const $root = options.local ? sys.cwd() : "/tmp";
    // make temporary directory and ensure it exists
    const $path = await handle(["mktemp", "-d", "-p", $root, "tmp.XXXXXX"], { script: "fs/make_temp_dir" }) ?? "";
    if (await isNotDir($path))
        write.error("fs/make_temp_dir", "Unable to create temporary directory.");
    return $path;
}
/**
 * Default options for read() function.
 */
const DEFAULT_READ_OPTIONS = {
    quiet: false
};
/**
 * Read a file, trim contents and return. Throws an error if the file does not exist, unless quiet is set.
 *
 * @param path File path (relative or absolute).
 * @param options Function options.
 * @returns Trimmed file contents.
 */
export async function read(path, options = {}) {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_READ_OPTIONS, ...options };
    // check path
    const $info = typeof path === "string" ? await pathInfo(path) : path;
    // file exists so get and trim contents
    if ($info.exists && $info.isFile)
        return (await sys.readTextFile($info.path)).trim();
    // if quiet is enabled, write to debug output and return blank string - otherwise throw an error
    const $error = `File does not exist: ${$info.path}.`;
    if ($opt.quiet) {
        write.debug("fs/read", "%s", $error);
        return "";
    }
    write.error("fs/read", "%s", $error);
}
