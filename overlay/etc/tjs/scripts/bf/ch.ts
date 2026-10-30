import * as env from "./env.ts";
import * as fs from "./fs.ts";
import { handle } from "./handle.ts";
import * as _ from "./util.ts";
import * as write from "./write.ts";

/**
 * Options for apply() function.
 */
export interface ChOptions {
    /** Use chmod: set permissions to this mode. */
    mode?: string;
    /** Use chown: set ownership to this user & group. */
    owner?: string;
    /** Add -R to chmod / chown to recurse (overrides type if that is set too). */
    recurse?: boolean;
    /** Apply to directories (d), files (f) or symlinks (l) within each path. */
    type?: fs.FindType;
}

/**
 * Apply ownership or permissions values to files and directories.
 *
 * @param paths The paths to which to apply ch operations.
 * @param options Function options.
 */
export async function apply(paths: string[], options: ChOptions = {}): Promise<void> {
    for (const $path of paths) {
        // if recurse is set, execute chmod / chown on each path with recursion
        if (options.recurse) {
            if (options.mode) await modRecurse($path, options.mode);
            if (options.owner) await ownRecurse($path, options.owner);
        }
        // if type is set, find all paths of type within each path and execute chmod / chown on them
        else if (options.type) {
            if (options.mode) await modType($path, options.type, options.mode);
            if (options.owner) await ownType($path, options.type, options.owner);
        }
        // otherwise, execute chmod / chown on each path
        else {
            if (options.mode) await mod($path, options.mode);
            if (options.owner) await own($path, options.owner);
        }
    }
}

/**
 * Apply permissions for a row in a ch.d file:
 *   1. file / directory path
 *   2. owner (for chown)
 *   3. optional: file mode (for chmod)
 *   4. optional: directory mode (for chmod)
 *
 * @param row Row values - with fewer than two values nothing is done.
 */
export async function applyRow(row: string[]): Promise<void> {
    if (row.length < 2) return;
    const [$path, $owner, $fmode, $dmode] = row;

    // apply ownership changes
    await ownRecurse($path, $owner);

    // apply mode changes
    if ($fmode) await modType($path, "f", $fmode);
    if ($dmode) await modType($path, "d", $dmode);
}

/**
 * Apply each row in a ch.d file (see applyRow()).
 *
 * @param file Path to the file, or the name of a file in BF_ETC_CH_D.
 */
export async function applyFile(file: string): Promise<void> {
    // get path and ensure permissions file exists
    const $path = (await fs.pathInfo(file)).isFile ? file : `${env.get("ETC_CH_D")}/${file}`;
    if (await fs.isNotFile($path)) write.error("ch/apply_file", "Unable to find file '%s'.", file);

    write.info("ch/apply_file", "Applying %s.", $path);
    for (const $line of _.splitLines(await fs.read($path))) {
        await applyRow($line.split(" ").filter(($x) => $x != ""));
    }
}

/**
 * Run an external command on path, if it exists - an error is thrown if the command fails.
 *
 * @param path File / directory path.
 * @param script Name to use in debug / error output.
 * @param args Command and arguments.
 */
async function onPath(path: string, script: string, args: string[]): Promise<void> {
    write.debug(script, " .. %s", args.join(" "));
    if ((await fs.pathInfo(path)).exists) await handle(args, { script: script, ignoreSuccess: true });
}

/** Apply chmod to path. */
function mod(path: string, mode: string): Promise<void> {
    return onPath(path, "ch/apply_mod", ["chmod", mode, path]);
}

/** Apply chmod to path recursively. */
function modRecurse(path: string, mode: string): Promise<void> {
    return onPath(path, "ch/apply_mod_recurse", ["chmod", "-R", mode, path]);
}

/** Apply chmod to all paths of type under base. */
function modType(base: string, type: fs.FindType, mode: string): Promise<void> {
    return onPath(base, "ch/apply_mod_type", ["busybox", "find", base, "-type", type, "-exec", "chmod", mode, "{}", "+"]);
}

/** Apply chown to path. */
function own(path: string, owner: string): Promise<void> {
    return onPath(path, "ch/apply_own", ["chown", owner, path]);
}

/** Apply chown to path recursively. */
function ownRecurse(path: string, owner: string): Promise<void> {
    return onPath(path, "ch/apply_own_recurse", ["chown", "-R", owner, path]);
}

/** Apply chown to all paths of type under base. */
function ownType(base: string, type: fs.FindType, owner: string): Promise<void> {
    return onPath(base, "ch/apply_own_type", ["busybox", "find", base, "-type", type, "-exec", "chown", owner, "{}", "+"]);
}
