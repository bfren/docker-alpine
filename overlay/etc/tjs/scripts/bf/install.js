import * as build from "./build.js";
import * as ch from "./ch.js";
import { clean } from "./clean.js";
import * as env from "./env.js";
import * as fs from "./fs.js";
import { handle } from "./handle.js";
import { image } from "./image.js";
import * as sys from "./sys.js";
import * as write from "./write.js";
import { x } from "./x.js";
/**
 * System directories that image overlays copy files into - COPY gives existing directories the permissions of the
 * matching directories in the build context, which are 0777 when building from a Windows drive.
 */
const SYSTEM_DIRS = [
    "/",
    "/etc",
    "/usr",
    "/usr/bin",
    "/usr/lib",
    "/usr/local",
    "/usr/local/bin",
    "/usr/local/sbin",
    "/usr/sbin",
    "/usr/share",
    "/var",
    "/var/lib",
];
/**
 * Run standard installation for the container:
 *   - show build information
 *   - show bfren environment
 *   - set permissions
 *   - run container's installation script
 *   - store image info
 *   - run cleanup
 *   - output image info
 */
export async function install() {
    // output build info
    write.info("install", "Build information.");
    await build.show();
    // output BF config
    write.info("install", "bfren platform environment variables.");
    env.show();
    // remove TypeScript sources and the .js extension from bf executables
    const $bin = "/usr/bin/bf";
    for (const $name of await sys.readDir($bin)) {
        const $path = `${$bin}/${$name}`;
        if ($name.endsWith(".ts"))
            await sys.remove($path);
        else if ($name.endsWith(".js"))
            await sys.rename($path, $path.slice(0, -".js".length));
    }
    // set permissions
    write.info("install", "Setting permissions.");
    await secureSystemDirs();
    await env.applyPerms();
    const $root = "root:root";
    await ch.apply(["/etc/tjs", $root, "0644", "0755"]);
    await ch.apply(["/init", $root, "0500"]);
    await ch.apply(["/test", $root, "0500"]);
    await ch.apply(["/tmp", $root, "1777", "1777"]);
    await ch.apply([$bin, $root, "0555"]);
    // run install script in /tmp
    const $install = "/tmp/install.js";
    if (await fs.isNotFile($install)) {
        write.debug("install", "%s does not exist.", $install);
    }
    else {
        write.info("install", "Executing %s.", $install);
        await x($install);
    }
    // store versions
    write.info("install", "Storing image information.");
    const $etc = env.get("ETC");
    await sys.writeTextFile(`${$etc}/IMAGE`, env.get("IMAGE").replace("docker-", ""));
    await sys.writeTextFile(`${$etc}/VERSION`, env.get("VERSION"));
    // clean installation files / caches etc
    write.info("install", "Running cleanup.");
    await clean();
    // all finished
    write.ok("install", "Installation complete.");
    await image();
}
/**
 * Remove group and other write permission from system directories that exist - e.g. Debian 13's adduser refuses to
 * run if a directory on PATH is world-writable.
 *
 * @param root Prefix added to each directory, so tests can use a temporary directory.
 */
export async function secureSystemDirs(root = "") {
    const $dirs = [];
    for (const $dir of SYSTEM_DIRS.map(($x) => `${root}${$x}`)) {
        if (await fs.isDir($dir))
            $dirs.push($dir);
    }
    await handle(["chmod", "go-w", ...$dirs], { script: "install/secure_system_dirs", ignoreSuccess: true });
}
