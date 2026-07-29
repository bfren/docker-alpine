import * as exec from "./exec.js";
import * as write from "./write.js";
// bf environment constant
const ENV = {};
// path to the environment variable store
const ENV_DIR = "/etc/bf/env.d";
// bfren platform prefix for namespacing environment variables
const PREFIX = "BF_";
/**
 * Adds the BF_ prefix to key.
 *
 * @param key Environment variable key.
 * @returns Prefixed key.
 */
function add_prefix(key) {
    return `${PREFIX}${key}`;
}
/**
 * Returns true if key exists in the environment and is equal to 1.
 *
 * @param key Environment variable key.
 * @param add_prefix Add BF_ prefix to key before getting value.
 */
export function check(key, add_prefix = true) {
    const $value = "1";
    return get(key, { add_prefix: add_prefix, safe: true }) == $value;
}
/**
 * Returns true if the BF_DEBUG environment variable is set to 1.
 *
 * @returns Whether or not BF_DEBUG environment variable is set to 1.
 */
export function debug() {
    return check("DEBUG");
}
/**
 * Returns true if key does not exist in the environment, or does with an empty value.
 *
 * @param key Environment variable key.
 * @param add_prefix Add BF_ prefix to key before getting value.
 */
export function empty(key, add_prefix = true) {
    const $value = "";
    return get(key, { add_prefix: add_prefix, safe: true }) == $value;
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
 * Get a value from system environment.
 *
 * @param key Environment variable key.
 * @param options Function options.
 * @returns Environment variable value.
 */
export function get(key, options = {}) {
    // merge default options with whatever has been passed to this function
    const opt = { ...DEFAULT_GET_OPTIONS, ...options };
    // add prefix if required
    const $prefixed = opt.add_prefix ? add_prefix(key) : key;
    // return the value if it exists
    const value = tjs.env[$prefixed];
    if (value != null)
        return value;
    // return default value
    if (opt.default_value != null)
        return opt.default_value;
    // return empty string
    if (opt.safe)
        return "";
    // output with error
    throw `Unable to get environment variable (${$prefixed}).`;
}
/**
 * Load environment from ENV_DIR.
 */
export async function load() {
    // use envdir to read environment values from ENV_DIR
    const $result = await exec.run("env", ["-i", "envdir", ENV_DIR, "env"]);
    if ($result.status != 0) {
        throw write.error("Unable to load environment variables from '%s': %s.", ENV_DIR, $result.stderr);
    }
    // split output based on newline, and parse each as KEY=VAL
    $result.stdout.split(/\r?\n/).forEach((line) => {
        // skip blank lines
        if (!line)
            return;
        // split on first '=' (variables can include '=' as part of their value)
        const $idx = line.indexOf("=");
        if ($idx == -1)
            return;
        // get variable key and value
        const $key = line.slice(0, $idx).trim();
        const $val = line.slice($idx + 1).trim();
        // set environment value
        tjs.env[$key] = $val;
        write.debug("%s = %s", "env.load", $key, $val);
    });
}
/**
 * Default options for set() function.
 */
const DEFAULT_SET_OPTIONS = {
    add_prefix: true,
};
/**
 * Persist a value to system environment.
 *
 * @param key Environment variable key.
 * @param val Value to set.
 * @param options Function options.
 */
export async function set(key, val, options = {}) {
    // merge default options with whatever has been passed to this function
    const opt = { ...DEFAULT_SET_OPTIONS, ...options };
    // trim input
    const $key = key.trim();
    const $val = String(val).trim();
    // add prefix if required
    const $prefixed = opt.add_prefix ? add_prefix($key) : $key;
    // persist to filesystem
    const $path = `${ENV_DIR}/${$prefixed}`;
    await tjs.writeFile($path, $val);
    // set tjs.env value
    tjs.env[$prefixed] = $val;
    write.debug("env.set", "%s = %s", $prefixed, $val);
}
export async function store() {
    // do not store these environment variables - it messes with stuff...
    const $ignore = [
        "CURRENT_FILE",
        "FILE_PWD",
        "HOSTNAME",
        "PWD",
    ];
    // loop through system environment and persist
    for (const [$key, $val] of Object.entries(tjs.env)) {
        // do not store ignored variables
        if ($ignore.includes($key))
            continue;
        // persist to filesystem
        const $path = `${ENV_DIR}/${$key}`;
        await tjs.writeFile($path, $val);
    }
}
