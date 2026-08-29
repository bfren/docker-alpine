import path from "tjs:path";
import * as build from "./build.js";
import * as ch from "./ch.js";
import * as env from "./env.js";
import * as write from "./write.js";
/**
 * Run standard installation for the container:
 *   - show build information
 *   - show bfren environment
 *   - run container's installation script
 *   - set permissions
 *   - store image info
 *   - run cleanup
 *   - output image info
 */
export async function install() {
    // output build info
    write.info("install", "Build information.");
    await build.show();
    // output BF config
    write.info("install", "bfren environment variables.");
    env.show();
    // remove and rename bf executable files
    const $bin = "/usr/local/bin/bf";
    await tjs.remove(`${$bin}/bf-*.ts`);
    const $dir = await tjs.readDir($bin);
    for await (const $exec of $dir) {
        const $ext = path.extname($exec.name);
        await tjs.rename($exec.name, $exec.name.replace($ext, ""));
    }
    // set permissions
    const $root = "root:root";
    await Promise.all([
        ch.apply("/etc/nu", $root, { fmode: "0666", dmode: "0777" }),
        ch.apply("/init", $root, { fmode: "0500" }),
        ch.apply("/test", $root, { fmode: "0500" }),
        ch.apply("/tmp", $root, { fmode: "1777", dmode: "1777" }),
        ch.apply($bin, $root, { fmode: "0555" })
    ]);
}
