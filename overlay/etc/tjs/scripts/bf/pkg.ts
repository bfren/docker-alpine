import { handle } from "./handle.ts";
import * as write from "./write.ts";

/**
 * Perform a package action, outputting any errors.
 *
 * @param name Name of the action.
 * @param description Description of the action for logs.
 * @param cmd The apk command to run.
 * @param args Command arguments.
 */
async function action(name: string, description: string, cmd: string, args: string[]): Promise<void> {
    const $script = `pkg/${name}`;
    const $joined = args.join(" ");

    write.debug($script, "%s: %s.", description, $joined);
    await handle(["apk", cmd, "--no-cache", ...args], {
        script: $script,
        dumpResult: `${description} packages`,
        ignoreSuccess: true,
        onFailure: ($code, $err) => write.error($script, "Error %d %s packages: %s.\n%s", $code, description.toLowerCase(), $joined, $err)
    });
}

/**
 * Use apk to install a list of packages.
 *
 * @param args List of packages to add / arguments.
 */
export function install(args: string[]): Promise<void> {
    return action("install", "Installing", "add", args);
}

/**
 * Use apk to remove a list of packages.
 *
 * @param args List of packages to delete / arguments.
 */
export function remove(args: string[]): Promise<void> {
    return action("remove", "Removing", "del", args);
}

/**
 * Use apk to upgrade a list of packages.
 *
 * @param args List of packages to upgrade / arguments.
 */
export function upgrade(args: string[] = []): Promise<void> {
    return action("upgrade", "Upgrading", "upgrade", args);
}
