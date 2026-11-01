import { handle } from "./handle.ts";
import * as sys from "./sys.ts";
import * as _ from "./util.ts";
import * as write from "./write.ts";

/**
 * Options for pathInfo() function.
 */
export interface PathInfoOptions {
    followSymlinks?: boolean
}

/**
 * Default options for pathInfo() function.
 */
const DEFAULT_PATHINFO_OPTIONS: Required<PathInfoOptions> = {
    followSymlinks: true
}

/**
 * Return type for pathInfo() function.
 */
export interface PathInfo {
    /** Absolute path (if symlinks are followed). */
    path: string,
    /** True if the path exists. */
    exists: boolean,
    /** True if the path is a file. */
    isFile: boolean,
    /** True if the path is a directory. */
    isDirectory: boolean,
    /** True if the path is a symlink (only when symlinks are not followed). */
    isSymlink: boolean,
    /** Access to the stat result object. */
    stat?: sys.StatResult
}

/**
 * Get info relating to a path.
 *
 * @param path Absolute or relative path to a file / directory / symlink.
 * @param options Function options.
 * @returns PathInfo object.
 */
export async function pathInfo(path: string, options: PathInfoOptions = {}): Promise<PathInfo> {
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
        }
    } catch {
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
 * Filesystem object types supported by posix find.
 */
export type FindType = "d" | "f" | "l";

/**
 * Check type is valid (i.e. supported by posix find).
 *
 * @param type Type to check - directories (d), files (f) or symlinks (l).
 */
function checkType(type: string): void {
    if (!["d", "f", "l"].includes(type)) write.error("fs/check_type", "%s is not supported.", type);
}

/**
 * Use posix find to search basePath, returning matching paths - or an empty list if basePath does not exist or
 * find fails.
 *
 * @param basePath Base path to search.
 * @param args Arguments to add to find.
 * @param text Text to use when dumping a failed result.
 */
async function find(basePath: string, args: string[], text: string): Promise<string[]> {
    if (!(await pathInfo(basePath)).exists) return [];

    return handle(["busybox", "find", basePath, "-xdev", ...args], {
        script: "fs/find",
        dumpResult: text,
        onFailure: () => [],
        onSuccess: ($out) => _.splitLines($out).filter(($x) => $x != "")
    }) as Promise<string[]>;
}

/**
 * Find all paths called name in basePath.
 *
 * @param basePath Base path to search.
 * @param name Name to search for within basePath.
 * @param type Limit results to paths of this type - directories (d), files (f) or symlinks (l).
 * @returns Matching paths.
 */
export async function findName(basePath: string, name: string, type: FindType = "f"): Promise<string[]> {
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
export async function findType(basePath: string, type: FindType): Promise<string[]> {
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
export async function findTypeAcc(basePaths: string[], type: FindType): Promise<string[]> {
    return (await Promise.all(basePaths.map(($x) => findType($x, type)))).flat();
}

/**
 * Returns the type of path without following symlinks (like Nushell's `path type`): "dir", "file", "symlink", or
 * "" if it does not exist.
 *
 * @param path Path to check.
 */
async function pathType(path: string): Promise<string> {
    const $info = await pathInfo(path, { followSymlinks: false });
    return $info.isSymlink ? "symlink" : $info.isDirectory ? "dir" : $info.isFile ? "file" : "";
}

/**
 * Returns true if path exists and is a directory (not a symlink to one).
 *
 * @param path Path to check.
 */
export async function isDir(path: string): Promise<boolean> {
    return (await pathType(path)) == "dir";
}

/**
 * Returns true unless path exists and is a directory.
 *
 * @param path Path to check.
 */
export async function isNotDir(path: string): Promise<boolean> {
    return (await pathType(path)) != "dir";
}

/**
 * Returns true unless path exists and is a file.
 *
 * @param path Path to check.
 */
export async function isNotFile(path: string): Promise<boolean> {
    return (await pathType(path)) != "file";
}

/**
 * Returns true unless path exists and is a symlink.
 *
 * @param path Path to check.
 */
export async function isNotSymlink(path: string): Promise<boolean> {
    return (await pathType(path)) != "symlink";
}

/**
 * Options for makeTempDir() function.
 */
export interface MakeTempDirOptions {
    /** Create the temporary directory in the current working directory instead of /tmp. */
    local?: boolean
}

/**
 * Make a temporary directory in /tmp.
 *
 * @param options Function options.
 * @returns Path to the new directory.
 */
export async function makeTempDir(options: MakeTempDirOptions = {}): Promise<string> {
    const $root = options.local ? sys.cwd() : "/tmp";

    // make temporary directory and ensure it exists
    const $path = await handle(["mktemp", "-d", "-p", $root, "tmp.XXXXXX"], { script: "fs/make_temp_dir" }) ?? "";
    if (await isNotDir($path)) write.error("fs/make_temp_dir", "Unable to create temporary directory.");

    return $path;
}

/**
 * Options for read() function.
 */
export interface ReadOptions {
    /** Return an empty string (and write a debug message) instead of throwing an error if the file does not exist. */
    quiet?: boolean
}

/**
 * Default options for read() function.
 */
const DEFAULT_READ_OPTIONS: Required<ReadOptions> = {
    quiet: false
};

/**
 * Read a file, trim contents and return. Throws an error if the file does not exist, unless quiet is set.
 *
 * @param path File path (relative or absolute).
 * @param options Function options.
 * @returns Trimmed file contents.
 */
export async function read(path: string | PathInfo, options: ReadOptions = {}): Promise<string> {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_READ_OPTIONS, ...options };

    // check path
    const $info = typeof path === "string" ? await pathInfo(path) : path;

    // file exists so get and trim contents
    if ($info.exists && $info.isFile) return (await sys.readTextFile($info.path)).trim();

    // if quiet is enabled, write to debug output and return blank string - otherwise throw an error
    const $error = `File does not exist: ${$info.path}.`;
    if ($opt.quiet) {
        write.debug("fs/read", "%s", $error);
        return "";
    }
    write.error("fs/read", "%s", $error);
}
