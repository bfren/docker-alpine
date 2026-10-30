import { makeTempDir } from "../bf/fs.ts";
import { handle } from "../bf/handle.ts";
import { secureSystemDirs } from "../bf/install.ts";
import * as sys from "../bf/sys.ts";

const { assert } = sys;


//======================================================================================================================
// secure_system_dirs
//======================================================================================================================

/** Create system directories in a temporary root, with the given permissions. */
async function makeDirs(dirs: Record<string, string>): Promise<string> {
    const $root = await makeTempDir();
    await handle(["chmod", "0755", $root]);
    for (const [$dir, $mode] of Object.entries(dirs)) {
        await handle(["sh", "-c", `mkdir -p ${$root}${$dir} && chmod ${$mode} ${$root}${$dir}`]);
    }
    return $root;
}

/** Returns the octal mode of path. */
async function mode(path: string): Promise<string> {
    return await handle(["stat", "-c", "%a", path]) ?? "";
}

export async function secure_system_dirs__removes_group_and_other_write_permission() {
    const $root = await makeDirs({ "/usr": "0777", "/usr/bin": "0775", "/etc": "0757" });

    await secureSystemDirs($root);

    assert.equal(await mode(`${$root}/usr`), "755");
    assert.equal(await mode(`${$root}/usr/bin`), "755");
    assert.equal(await mode(`${$root}/etc`), "755");
}

export async function secure_system_dirs__leaves_other_permissions_alone() {
    const $root = await makeDirs({ "/var": "0700", "/usr": "0751" });

    await secureSystemDirs($root);

    assert.equal(await mode(`${$root}/var`), "700");
    assert.equal(await mode(`${$root}/usr`), "751");
}

export async function secure_system_dirs__skips_symlinks_and_missing_directories() {
    const $root = await makeDirs({ "/usr": "0755", "/usr/bin": "0777" });
    await handle(["ln", "-s", "bin", `${$root}/usr/sbin`]);

    // most directories in the list do not exist in root - chmod would fail if they were not skipped
    await secureSystemDirs($root);

    assert.equal(await mode(`${$root}/usr/bin`), "755");
}
