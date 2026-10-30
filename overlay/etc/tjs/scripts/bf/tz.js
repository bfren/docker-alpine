import * as fs from "./fs.js";
import { handle } from "./handle.js";
import * as pkg from "./pkg.js";
import * as sys from "./sys.js";
import * as write from "./write.js";
/** Path to current timezone info. */
const LOCALTIME = "/etc/localtime";
/** Path to file containing name of current timezone. */
const TIMEZONE = "/etc/timezone";
/** Path to installed timezone definition files. */
const ZONEINFO = "/usr/share/zoneinfo";
/**
 * Set the container's timezone.
 *
 * @param name The name of the timezone to use.
 */
export async function tz(name) {
    // if current timezone is already name, do nothing
    if ((await fs.read(TIMEZONE, { quiet: true })) == name) {
        write.info("tz", "Timezone is already %s.", name);
        return;
    }
    // install timezone package
    write.debug("tz", "Installing tzdata packages.");
    await pkg.install(["--virtual", ".tz", "tzdata"]);
    // check the specified timezone exists
    const $zone = `${ZONEINFO}/${name}`;
    if (await fs.isNotFile($zone)) {
        await clean();
        write.error("tz", "%s is not a recognised timezone.", name);
    }
    // copy timezone info and write to file
    write.info("tz", "Setting timezone to %s.", name);
    await handle(["cp", $zone, LOCALTIME], { script: "tz", ignoreSuccess: true });
    await sys.writeTextFile(TIMEZONE, name);
    await clean();
}
/**
 * Remove tzdata packages and info.
 *
 * @param options Function options.
 */
export async function clean(options = {}) {
    const $dir = options.dir ?? ZONEINFO;
    write.debug("tz/clean", "Removing tzdata packages.");
    await pkg.remove([".tz"]);
    // if an image has installed tzdata itself (e.g. for .NET or PHP), removing the .tz virtual package leaves tzdata
    // installed - so keep its timezone definitions, otherwise applications that convert between timezones will fail
    if (await handle(["apk", "info", "-e", "tzdata"], { codeOnly: true }) == 0) {
        write.debug("tz/clean", "tzdata is installed, so timezone definitions have been kept.");
        return;
    }
    for (const $entry of await sys.readDir($dir).catch(() => []))
        await sys.remove(`${$dir}/${$entry}`);
}
/**
 * Return the name of the current timezone.
 */
export function current() {
    return fs.read(TIMEZONE);
}
