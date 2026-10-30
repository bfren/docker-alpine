import { handle } from "./handle.js";
import * as sys from "./sys.js";
import * as _ from "./util.js";
import * as write from "./write.js";
/** Path to the environment variable store. */
export const ENV_DIR = "/etc/bf/env.d";
/** bfren platform prefix for namespacing environment variables. */
export const PREFIX = "BF_";
/**
 * Adds the BF_ prefix to key, if required.
 *
 * @param key Environment variable key.
 * @param add_prefix Add BF_ prefix to key.
 * @returns Prefixed key.
 */
function prefixed(key, add_prefix = true) {
    return add_prefix ? `${PREFIX}${key}` : key;
}
/**
 * Default options for get() function.
 */
const DEFAULT_GET_OPTIONS = {
    default_value: null,
    add_prefix: true,
    safe: false
};
/**
 * Get a value from system environment - if default_value is not set and the variable does not exist (or is empty),
 * an error will be thrown unless safe is set.
 *
 * @param key Environment variable key.
 * @param options Function options.
 * @returns Environment variable value.
 */
export function get(key, options = {}) {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_GET_OPTIONS, ...options };
    const $prefixed = prefixed(key, $opt.add_prefix);
    // return the value if it exists
    const $value = sys.env[$prefixed];
    if (_.notEmpty($value))
        return $value;
    // return default value
    if (_.notEmpty($opt.default_value))
        return $opt.default_value;
    // return empty string
    if ($opt.safe)
        return "";
    // output with error
    write.error("env", "Unable to get environment variable %s.", $prefixed);
}
/**
 * Apply permissions for the environment variables directory.
 */
export async function applyPerms() {
    await handle(["chmod", "-R", "a+rwX", ENV_DIR], { ignoreError: true });
}
/**
 * Returns true if key exists in the environment and is equal to 1.
 *
 * @param key Environment variable key.
 * @param add_prefix Add BF_ prefix to key before getting value.
 */
export function check(key, add_prefix = true) {
    return test(key, "1", add_prefix);
}
/**
 * Returns true if the BF_DEBUG environment variable is set to 1.
 */
export function debug() {
    return check("DEBUG");
}
/**
 * Returns true if key does not exist in the environment, or is empty.
 *
 * @param key Environment variable key.
 * @param add_prefix Add BF_ prefix to key before getting value.
 */
export function empty(key, add_prefix = true) {
    return test(key, "", add_prefix);
}
/**
 * Load shared environment from ENV_DIR into the current environment, the way envdir does: the value is the first line
 * of each file with trailing spaces / tabs removed, and empty files are skipped.
 *
 * @param options Function options.
 */
export async function load(options = {}) {
    for (const $key of await sys.readDir(ENV_DIR)) {
        if ($key.startsWith("."))
            continue;
        // the file may have been removed since the directory was read
        const $val = await sys.readTextFile(`${ENV_DIR}/${$key}`).catch(() => "");
        const $first = _.splitLines($val)[0]?.replace(/[ \t]+$/, "") ?? "";
        if ($first)
            sys.env[$key] = $first;
    }
    // set current script
    if (options.set_executable)
        xSet(options.x_prefix);
}
/**
 * Save an environment variable to the current environment and ENV_DIR - an empty value unsets the variable.
 *
 * @param key Environment variable key.
 * @param val Value to set.
 * @param options Function options.
 */
export async function set(key, val, options = {}) {
    const $prefixed = prefixed(key.trim(), options.add_prefix ?? true);
    const $val = String(val ?? "").trim();
    // if the value is empty, unset the variable
    if ($val == "")
        return unset($prefixed, false);
    // save to current environment
    sys.env[$prefixed] = $val;
    // create persistence file and apply permissions
    await sys.writeTextFile(`${ENV_DIR}/${$prefixed}`, $val);
    await applyPerms();
    // output for debugging purposes
    write.debug("env/set", "%s=%s.", $prefixed, $val);
}
/**
 * Show all bfren platform environment variables.
 */
export function show() {
    const $vars = Object.entries(sys.env)
        .filter(([$key]) => $key.startsWith(PREFIX))
        .sort(([$a], [$b]) => $a.localeCompare($b, undefined, { numeric: true }));
    console.log(_.toTable(Object.fromEntries($vars)));
}
/**
 * Store incoming environment variables in ENV_DIR.
 */
export async function store() {
    // do not store these environment variables - it messes with stuff...
    const $ignore = [
        "CURRENT_FILE",
        "FILE_PWD",
        "HOME",
        "HOSTNAME",
        "PWD",
        "SHLVL",
        "TERM",
    ];
    // loop through system environment and persist
    for (const [$key, $val] of Object.entries(sys.env)) {
        if ($ignore.includes($key))
            continue;
        await sys.writeTextFile(`${ENV_DIR}/${$key}`, $val);
    }
    // apply permissions to files
    await applyPerms();
}
/**
 * Returns true if key is equal to value.
 *
 * @param key Environment variable key.
 * @param value The value to compare against.
 * @param add_prefix Add BF_ prefix to key before getting value.
 */
export function test(key, value, add_prefix = true) {
    return get(prefixed(key, add_prefix), { add_prefix: false, safe: true }) == value;
}
/**
 * Unset an environment variable and remove it from ENV_DIR.
 *
 * @param key Environment variable key.
 * @param add_prefix Add BF_ prefix to key.
 */
export async function unset(key, add_prefix = true) {
    const $prefixed = prefixed(key, add_prefix);
    // remove from the current environment
    delete sys.env[$prefixed];
    // delete persistence file (if it exists)
    await sys.remove(`${ENV_DIR}/${$prefixed}`).catch(() => { });
    // output for debugging purposes
    write.debug("env/unset", "%s removed.", $prefixed);
}
/**
 * Sets the BF_X environment variable to the name of the currently executing script - it is not persisted to ENV_DIR
 * as it only applies to the current operation.
 *
 * @param x_prefix If set, will be added before the name of the current script.
 * @param options Function options.
 */
export function xSet(x_prefix, options = {}) {
    // get name of current file
    const $current = options.override || (sys.script ? sys.path.basename(sys.script) : "");
    if (!$current)
        write.error("env/x_set", "Unable to determine current file - please use override.");
    sys.env[prefixed("X")] = x_prefix ? `${x_prefix}/${$current}` : $current;
}
