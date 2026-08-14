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
    /** Absolute path. */
    path: string,
    /** True if the path exists. */
    exists: boolean,
    /** True if the path is a file. */
    isFile: boolean,
    /** True if the path is a directory. */
    isDirectory: boolean,
    /** True if the path is a symlink. */
    isSymlink: boolean,
    /** Access to the stat result object. */
    stat?: tjs.StatResult
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
        const $path = await tjs.realPath(path);
        const $st = await ($opt.followSymlinks ? tjs.stat($path) : tjs.lstat($path));

        return {
            path: $path,
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
 * Options for read() function.
 */
export interface ReadOptions {
    quiet?: boolean
}

/**
 * Default options for read() function.
 */
const DEFAULT_READ_OPTIONS: Required<ReadOptions> = {
    quiet: false
};

/**
 * Read the contents of a file. Throws an error if the file does not exist or is unreadable,
 * unless quiet is set in options.
 *
 * @param path File path (relative or absolute).
 * @param options Function options.
 * @returns File contents.
 */
export async function read(path: string | PathInfo, options: ReadOptions = {}): Promise<string> {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_READ_OPTIONS, ...options };

    // check path
    const $info = typeof path === "string" ? await pathInfo(path) : path;

    // read file to string if it exists and is a file
    if ($info.exists && $info.isFile) {
        const $stream = await tjs.readFile($info.path);
        return $stream.toString();
    }
    // return empty string if quiet is set
    else if($opt.quiet) {
        return "";
    }

    // throw error
    throw write.error("fs.read", "Unable to read file '%s'.", path);
}
