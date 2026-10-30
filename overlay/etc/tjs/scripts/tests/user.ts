import { handle } from "../bf/handle.ts";
import * as sys from "../bf/sys.ts";
import { add, exists } from "../bf/user.ts";
import { randomChars } from "./lib/capture.ts";

const { assert } = sys;

/** Returns a random integer from min to max (inclusive). */
function randomInt(min: number, max: number): number {
    return min + Math.floor(Math.random() * (max - min + 1));
}

/** Returns trimmed getent output for key in database. */
async function getent(database: string, key: string): Promise<string> {
    return await handle(["getent", database, key]) ?? "";
}

/** Delete user name and their home directory. */
async function deleteUser(name: string): Promise<void> {
    await handle(["busybox", "deluser", name], { ignoreError: true });
    await sys.remove(`/home/${name}`).catch(() => { });
}


//======================================================================================================================
// exists
//======================================================================================================================

export async function exists__user_exists__returns_true() {
    assert.equal(await exists("root"), true);
}

export async function exists__user_does_not_exist__returns_false() {
    assert.equal(await exists(`t${randomChars()}`), false);
}


//======================================================================================================================
// add
//======================================================================================================================

export async function add__user_already_exists__returns_error() {
    const $result = await add("root").then(() => "no error", ($e: Error) => $e.message);

    assert.equal($result, "User root already exists.");
}

// Both cases run in one test: tests run in parallel, and busybox adduser / addgroup rewrite /etc/passwd and /etc/group
// without locking, so two tests adding users at the same time can overwrite each other's changes
export async function add__creates_user_with_uid_and_group__and_uses_gid_when_set() {
    // without gid: the group uses the UID
    let $name = `t${randomChars().slice(0, 8)}`;
    let $uid = randomInt(20000, 24999);

    await add($name, { uid: $uid });
    let $result = await getent("passwd", $name);
    const $group = await getent("group", $name);
    await deleteUser($name);

    assert.ok($result.includes(`:${$uid}:${$uid}:`), "add does not create user with the specified UID and matching GID");
    assert.ok($group.startsWith(`${$name}:`), "add does not create group");

    // with gid: the group uses the GID
    $name = `t${randomChars().slice(0, 8)}`;
    $uid = randomInt(25000, 27499);
    const $gid = randomInt(27500, 29999);

    await add($name, { uid: $uid, gid: $gid });
    $result = await getent("passwd", $name);
    await deleteUser($name);

    assert.ok($result.includes(`:${$uid}:${$gid}:`), "add does not use specified GID");
}
