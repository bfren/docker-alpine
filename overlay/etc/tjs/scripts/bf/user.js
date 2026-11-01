import { handle } from "./handle.js";
import * as write from "./write.js";
/**
 * Add a non-login user and group of the specified name, optionally specifying UID and GID.
 *
 * @param name The name of the user and group to add.
 * @param options Function options.
 */
export async function add(name, options = {}) {
    // if user exists show an error
    if (await exists(name))
        write.error("user/add", "User %s already exists.", name);
    // if GID is set, use it, otherwise use UID
    const $uid = options.uid ?? 1000;
    const $gid = options.gid ?? $uid;
    write.info("user/add", "Adding user %s with UID %d and GID %d.", name, $uid, $gid);
    // add group and user
    await addUserAndGroup(name, `/home/${name}`, $uid, $gid);
}
/**
 * Add a new user and group with the same name.
 *
 * @param name The name of the user and group to add.
 * @param home The user's home directory.
 * @param uid The user's UID.
 * @param gid The group's GID.
 */
export async function addUserAndGroup(name, home, uid, gid) {
    // explicitly use busybox executables to support both Alpine and Debian
    await handle(["busybox", "addgroup", "--gid", String(gid), name], { script: "user/add", ignoreSuccess: true });
    await handle(["busybox", "adduser", "--uid", String(uid), "--home", home, "--disabled-password", "--ingroup", name, name], { script: "user/add", ignoreSuccess: true });
}
/**
 * Checks whether or not user name exists in /etc/passwd.
 *
 * @param name The user name.
 */
export async function exists(name) {
    return await handle(["getent", "passwd", name], { codeOnly: true }) == 0;
}
