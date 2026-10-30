import { dump } from "./dump.js";
import * as sys from "./sys.js";
import * as write from "./write.js";
export async function handle(args, options = {}) {
    const $result = await sys.spawn(args);
    // if debugging is enabled, dump the result object (it won't show unless BF_DEBUG is 1)
    if (options.debug)
        dump($result);
    // return exit code
    if (options.codeOnly)
        return $result.status;
    // if ignoring success, return nothing - otherwise, run onSuccess (if it has been set) and return
    if ($result.status == 0) {
        if (options.ignoreSuccess)
            return undefined;
        return options.onSuccess ? options.onSuccess($result.stdout) : $result.stdout.trim();
    }
    // if ignoring errors, return stdout
    if (options.ignoreError)
        return $result.stdout.trim();
    // if we get here, the operation failed - dump the result object (it won't show unless BF_DEBUG is 1)
    if (options.dumpResult)
        dump($result, { text: options.dumpResult });
    // run onFailure (if it has been set) and return
    if (options.onFailure)
        return options.onFailure($result.status, $result.stderr);
    // write exit code and stderr
    write.error(options.script ?? "", "%d: %s", $result.status, $result.stderr.trim());
}
