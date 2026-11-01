import { dump } from "./dump.ts";
import * as sys from "./sys.ts";
import * as write from "./write.ts";

/**
 * Options for handle() function.
 */
export interface HandleOptions<T> {
    /** The name of the calling script or executable. */
    script?: string;
    /** Only return the exit code - overrides all other options. */
    codeOnly?: boolean;
    /** Dump the result object immediately before any processing. */
    debug?: boolean;
    /** On error, dump the full result object with this text. */
    dumpResult?: string;
    /** Ignore any errors and return trimmed stdout - overrides dumpResult and onFailure. */
    ignoreError?: boolean;
    /** Discard a successful result - overrides onSuccess. */
    ignoreSuccess?: boolean;
    /** On failure, run this with the exit code and stderr, and return its result. */
    onFailure?: (code: number, stderr: string) => T;
    /** On success, run this with (untrimmed) stdout, and return its result. */
    onSuccess?: (stdout: string) => T;
}

/**
 * Run an external executable and handle the result:
 *   - if the exit code is 0, trimmed stdout is returned
 *   - if the exit code is not 0, an error containing the exit code and trimmed stderr is thrown
 * Options change this behaviour - see HandleOptions.
 *
 * @param args The executable followed by its arguments.
 * @param options Function options.
 * @returns Exit code, stdout, the result of onSuccess / onFailure, or undefined (ignoreSuccess).
 */
export async function handle(args: string[], options: HandleOptions<never> & { codeOnly: true }): Promise<number>;
export async function handle<T = string>(args: string[], options?: HandleOptions<T>): Promise<T | string | undefined>;
export async function handle<T>(args: string[], options: HandleOptions<T> = {}): Promise<T | string | number | undefined> {
    const $result = await sys.spawn(args);

    // if debugging is enabled, dump the result object (it won't show unless BF_DEBUG is 1)
    if (options.debug) dump($result);

    // return exit code
    if (options.codeOnly) return $result.status;

    // if ignoring success, return nothing - otherwise, run onSuccess (if it has been set) and return
    if ($result.status == 0) {
        if (options.ignoreSuccess) return undefined;
        return options.onSuccess ? options.onSuccess($result.stdout) : $result.stdout.trim();
    }

    // if ignoring errors, return stdout
    if (options.ignoreError) return $result.stdout.trim();

    // if we get here, the operation failed - dump the result object (it won't show unless BF_DEBUG is 1)
    if (options.dumpResult) dump($result, { text: options.dumpResult });

    // run onFailure (if it has been set) and return
    if (options.onFailure) return options.onFailure($result.status, $result.stderr);

    // write exit code and stderr
    write.error(options.script ?? "", "%d: %s", $result.status, $result.stderr.trim());
}
