import { check, debug, empty, ENV_DIR, get, PREFIX, set, unset, xSet } from "../bf/env.ts";
import { pathInfo } from "../bf/fs.ts";
import * as sys from "../bf/sys.ts";
import { randomChars, runScript, withEnv } from "./lib/capture.ts";

const { assert } = sys;

/** Returns true if key has been persisted to ENV_DIR. */
async function stored(key: string): Promise<boolean> {
    return (await pathInfo(`${ENV_DIR}/${key}`)).exists;
}

/** Remove key from ENV_DIR (if it exists). */
async function rmStored(key: string): Promise<void> {
    await sys.remove(`${ENV_DIR}/${key}`).catch(() => { });
}


//======================================================================================================================
// main (get)
//======================================================================================================================

export function main__case_matches__returns_value() {
    const $key = randomChars();
    const $value = randomChars();

    const $result = withEnv({ [$key]: $value }, () => get($key, { add_prefix: false }));

    assert.equal($result, $value, "does not return correct value with case-sensitive key");
}

export function main__case_does_not_match__returns_default_value() {
    const $key = `k${randomChars()}`;
    const $value = randomChars();
    const $default = randomChars();

    const $result = withEnv({ [$key]: $value }, () => get($key.toUpperCase(), { add_prefix: false, default_value: $default }));

    assert.equal($result, $default, "does not return default value with case-sensitive key");
}

export function main__returns_value_for_prefixed_key() {
    const $key = randomChars();
    const $value = randomChars();

    const $result = withEnv({ [PREFIX + $key]: $value }, () => get($key));

    assert.equal($result, $value, "does not return value for prefixed key");
}

export function main__with_no_prefix__returns_value_for_unprefixed_key() {
    const $key = randomChars();
    const $value = randomChars();

    const $result = withEnv({ [$key]: $value }, () => get($key, { add_prefix: false }));

    assert.equal($result, $value, "does not return value for unprefixed key");
}

export function main__no_value__with_default__returns_default_value() {
    const $default = randomChars();

    const $result = get(randomChars(), { default_value: $default });

    assert.equal($result, $default, "does not return default value when key is not set");
}

export function main__no_value__with_safe__returns_safe_string() {
    const $result = get(randomChars(), { safe: true });

    assert.equal($result, "", "does not return empty string with key is not set");
}


//======================================================================================================================
// check
//======================================================================================================================

export function check__value_is_1__returns_true() {
    const $key = randomChars();

    const $result = withEnv({ [$key]: "1" }, () => check($key, false));

    assert.equal($result, true, "check does not return true when value is '1'");
}

export function check__value_is_not_1__returns_false() {
    const $key = randomChars();

    const $result = withEnv({ [$key]: randomChars() }, () => check($key, false));

    assert.equal($result, false, "check does not return false when value is not '1'");
}

export function check__value_is_not_set__returns_false() {
    const $result = check(randomChars(), false);

    assert.equal($result, false, "check does not return false when value is not set");
}


//======================================================================================================================
// debug
//======================================================================================================================

export function debug__value_is_1__returns_true() {
    const $result = withEnv({ BF_DEBUG: "1" }, debug);

    assert.equal($result, true, "debug does not return true when value is '1'");
}

export function debug__value_is_not_1__returns_false() {
    const $result = withEnv({ BF_DEBUG: randomChars() }, debug);

    assert.equal($result, false, "debug does not return false when value is not '1'");
}

export function debug__value_is_not_set__returns_false() {
    const $result = withEnv({ BF_DEBUG: undefined }, debug);

    assert.equal($result, false, "debug does not return false when value is not set");
}


//======================================================================================================================
// empty
//======================================================================================================================

export function empty__value_is_empty__returns_true() {
    const $key = randomChars();

    const $result = withEnv({ [$key]: "" }, () => empty($key, false));

    assert.equal($result, true, "empty does not return true when value is ''");
}

export function empty__value_is_not_set__returns_true() {
    const $result = empty(randomChars(), false);

    assert.equal($result, true, "empty does not return true when value is not set");
}

export function empty__value_is_not_empty__returns_false() {
    const $key = randomChars();

    const $result = withEnv({ [$key]: randomChars() }, () => empty($key, false));

    assert.equal($result, false, "empty does not return false when value is not empty");
}


//======================================================================================================================
// store - run in a child process as store saves the whole environment
//======================================================================================================================

const STORE = `import * as bf from "bf";\nawait bf.env.store();\n`;

export async function store__saves_environment_variable() {
    const $key = randomChars();
    const $value = randomChars();

    await runScript(STORE, { [$key]: $value, PATH: sys.env.PATH });
    const $result = await sys.readTextFile(`${ENV_DIR}/${$key}`);
    await rmStored($key);

    assert.equal($result, $value, "store does not save environment variable");
}

export async function store__does_not_save_process_variables() {
    const $ignored = ["CURRENT_FILE", "FILE_PWD", "HOME", "HOSTNAME", "PWD", "SHLVL", "TERM"];
    for (const $x of $ignored) await rmStored($x);

    await runScript(STORE, { ...Object.fromEntries($ignored.map(($x) => [$x, randomChars()])), PATH: sys.env.PATH });
    const $result = [];
    for (const $x of $ignored) if (await stored($x)) $result.push($x);

    assert.deepEqual($result, [], "store saves variables that only apply to the current process");
}


//======================================================================================================================
// set
//======================================================================================================================

export async function set__saves_to_environment_and_store() {
    const $key = randomChars();
    const $value = randomChars();
    const $prefixed = PREFIX + $key;

    await set($key, $value);
    const $resultEnv = sys.env[$prefixed];
    const $resultFile = await sys.readTextFile(`${ENV_DIR}/${$prefixed}`);
    await unset($key);

    assert.equal($resultEnv, $value, "set does not add value to environment");
    assert.equal($resultFile, $value, "set does not persist value to store");
}

export async function set__with_no_prefix__does_not_add_prefix() {
    const $key = randomChars();
    const $value = randomChars();

    await set($key, $value, { add_prefix: false });
    const $resultEnv = sys.env[$key];
    const $resultFile = await sys.readTextFile(`${ENV_DIR}/${$key}`);
    await unset($key, false);

    assert.equal($resultEnv, $value, "set does not add unprefixed value to environment");
    assert.equal($resultFile, $value, "set does not persist unprefixed value to store");
}

export async function set__empty_value__unsets_variable() {
    const $key = randomChars();
    const $prefixed = PREFIX + $key;

    await set($key, "value");
    await set($key, "");

    assert.equal(sys.env[$prefixed], undefined, "set with empty value does not remove value from environment");
    assert.equal(await stored($prefixed), false, "set with empty value does not remove value from store");
}


//======================================================================================================================
// unset
//======================================================================================================================

export async function unset__removes_from_environment_and_store() {
    const $key = randomChars();
    const $prefixed = PREFIX + $key;

    await set($key, "value");
    await unset($key);

    assert.equal(sys.env[$prefixed], undefined, "unset does not remove value from environment");
    assert.equal(await stored($prefixed), false, "unset does not remove value from store");
}

export async function unset__with_no_prefix__does_not_add_prefix() {
    const $key = randomChars();

    await set($key, "value", { add_prefix: false });
    await unset($key, false);

    assert.equal(sys.env[$key], undefined, "unset does not remove unprefixed value from environment");
    assert.equal(await stored($key), false, "unset does not remove unprefixed value from store");
}

export async function unset__variable_does_not_exist__does_not_error() {
    const $key = randomChars();

    await unset($key);

    assert.equal(sys.env[PREFIX + $key], undefined);
}


//======================================================================================================================
// load - run in a child process as load reads the whole store
//======================================================================================================================

export async function load__loads_stored_variables_into_environment() {
    const $key = randomChars();
    const $value = randomChars();
    const $prefixed = PREFIX + $key;

    await sys.writeTextFile(`${ENV_DIR}/${$prefixed}`, $value);
    const $result = await runScript(`import * as bf from "bf";\nawait bf.env.load();\nconsole.log(bf.sys.env.${$prefixed} ?? "");\n`);
    await rmStored($prefixed);

    assert.equal($result, $value, "load does not load stored variable into environment");
}


//======================================================================================================================
// x_set
//======================================================================================================================

export function x_set__with_override__sets_bf_x() {
    const $name = randomChars();

    const $result = withEnv({ BF_X: undefined }, () => { xSet(undefined, { override: $name }); return sys.env.BF_X; });

    assert.equal($result, $name, "x_set does not use override");
}

export function x_set__with_prefix__adds_prefix() {
    const $name = randomChars();
    const $prefix = randomChars();

    const $result = withEnv({ BF_X: undefined }, () => { xSet($prefix, { override: $name }); return sys.env.BF_X; });

    assert.equal($result, `${$prefix}/${$name}`, "x_set does not add prefix");
}

export async function x_set__without_override__uses_current_file_basename() {
    const $name = `${randomChars()}.js`;

    const $result = await runScript(`import * as bf from "bf";\nbf.env.xSet();\nconsole.log(bf.sys.env.BF_X);\n`, {}, $name);

    assert.equal($result, $name, "x_set does not use current file basename");
}

export async function x_set__is_not_persisted_to_store() {
    withEnv({ BF_X: undefined }, () => xSet(undefined, { override: randomChars() }));

    assert.equal(await stored("BF_X"), false, "x_set persists BF_X to store");
}
