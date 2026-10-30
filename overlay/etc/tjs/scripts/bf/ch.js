import * as env from "./env.js";
import * as fs from "./fs.js";
import { handle } from "./handle.js";
import * as _ from "./util.js";
import * as write from "./write.js";
/**
 * Apply ownership or permissions values to files and directories.
 *
 * @param paths The paths to which to apply ch operations.
 * @param options Function options.
 */
export async function ch(paths, options = {}) {
    for (const $path of paths) {
        // if recurse is set, execute chmod / chown on each path with recursion
        if (options.recurse) {
            if (options.mode)
                await modRecurse($path, options.mode);
            if (options.owner)
                await ownRecurse($path, options.owner);
        }
        // if type is set, find all paths of type within each path and execute chmod / chown on them
        else if (options.type) {
            if (options.mode)
                await modType($path, options.type, options.mode);
            if (options.owner)
                await ownType($path, options.type, options.owner);
        }
        // otherwise, execute chmod / chown on each path
        else {
            if (options.mode)
                await mod($path, options.mode);
            if (options.owner)
                await own($path, options.owner);
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
export async function apply(row) {
    if (row.length < 2)
        return;
    const [$path, $owner, $fmode, $dmode] = row;
    // apply ownership changes
    await ownRecurse($path, $owner);
    // apply mode changes
    if ($fmode)
        await modType($path, "f", $fmode);
    if ($dmode)
        await modType($path, "d", $dmode);
}
/**
 * Apply each row in a ch.d file (see apply()).
 *
 * @param file Path to the file, or the name of a file in BF_ETC_CH_D.
 */
export async function applyFile(file) {
    // get path and ensure permissions file exists
    const $path = (await fs.pathInfo(file)).isFile ? file : `${env.get("ETC_CH_D")}/${file}`;
    if (await fs.isNotFile($path))
        write.error("ch/apply_file", "Unable to find file '%s'.", file);
    write.info("ch/apply_file", "Applying %s.", $path);
    for (const $line of _.splitLines(await fs.read($path))) {
        await apply($line.split(" ").filter(($x) => $x != ""));
    }
}
/**
 * Run an external command on path, if it exists - an error is thrown if the command fails.
 *
 * @param path File / directory path.
 * @param script Name to use in debug / error output.
 * @param args Command and arguments.
 */
async function onPath(path, script, args) {
    write.debug(script, " .. %s", args.join(" "));
    if ((await fs.pathInfo(path)).exists)
        await handle(args, { script: script, ignoreSuccess: true });
}
/** Apply chmod to path. */
function mod(path, mode) {
    return onPath(path, "ch/apply_mod", ["chmod", mode, path]);
}
/** Apply chmod to path recursively. */
function modRecurse(path, mode) {
    return onPath(path, "ch/apply_mod_recurse", ["chmod", "-R", mode, path]);
}
/** Apply chmod to all paths of type under base. */
function modType(base, type, mode) {
    return onPath(base, "ch/apply_mod_type", ["busybox", "find", base, "-type", type, "-exec", "chmod", mode, "{}", "+"]);
}
/** Apply chown to path. */
function own(path, owner) {
    return onPath(path, "ch/apply_own", ["chown", owner, path]);
}
/** Apply chown to path recursively. */
function ownRecurse(path, owner) {
    return onPath(path, "ch/apply_own_recurse", ["chown", "-R", owner, path]);
}
/** Apply chown to all paths of type under base. */
function ownType(base, type, owner) {
    return onPath(base, "ch/apply_own_type", ["busybox", "find", base, "-type", type, "-exec", "chown", owner, "{}", "+"]);
}
