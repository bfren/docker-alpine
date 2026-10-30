import * as env from "./env.js";
import * as fs from "./fs.js";
import * as sys from "./sys.js";
import * as _ from "./util.js";
/**
 * The name of the file containing information about the image.
 */
export const BUILD_FILE = "BUILD";
/**
 * Each build log entry is 'Key: Value'.
 */
const SEPARATOR = ": ";
/**
 * Parse and return information from the build log.
 *
 * @returns Build log entries, in order.
 */
export async function get() {
    const $entries = _.splitLines(await fs.read(`${env.get("ETC")}/${BUILD_FILE}`))
        .filter(($line) => $line.includes(SEPARATOR))
        .map(($line) => [$line.slice(0, $line.indexOf(SEPARATOR)), $line.slice($line.indexOf(SEPARATOR) + SEPARATOR.length)]);
    return Object.fromEntries($entries);
}
/**
 * Add an entry to the build log.
 *
 * @param key Key e.g. 'Platform'.
 * @param value Value e.g. 'linux/amd64'.
 */
export async function add(key, value) {
    // add a newline so the next entry is added to the next line
    await sys.appendTextFile(`${env.get("ETC")}/${BUILD_FILE}`, `${key}${SEPARATOR}${value}\n`);
}
/**
 * Show information from the build log.
 */
export async function show() {
    console.log(_.toTable(await get()));
}
