import * as sys from "./sys.ts";

/**
 * Execute an external script, returning status, stderr and stdout.
 *
 * @param path The executable to run.
 * @param args Arguments to add to the executable.
 * @returns Result - including status, stderr and stdout.
 */
export function run(path: string, args: string[] = []): Promise<Result> {
    return sys.spawn([path, ...args]);
}

/**
 * External executable result.
 */
export type Result = sys.SpawnResult;