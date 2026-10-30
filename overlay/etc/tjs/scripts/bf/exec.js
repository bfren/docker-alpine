import * as sys from "./sys.js";
/**
 * Execute an external script, returning status, stderr and stdout.
 *
 * @param path The executable to run.
 * @param args Arguments to add to the executable.
 * @returns Result - including status, stderr and stdout.
 */
export function run(path, args = []) {
    return sys.spawn([path, ...args]);
}
