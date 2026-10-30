import * as sys from "./sys.js";
/**
 * Dump input value if debug is enabled, then return original value.
 *
 * @param input Value to dump.
 * @param options Function options.
 * @returns The original input unchanged.
 */
export function dump(input, options = {}) {
    // check BF_DEBUG directly so dump can be used everywhere (including env module)
    if (options.always || sys.env.BF_DEBUG == "1") {
        const $print = options.stderr ? console.error : console.log;
        // output optional text heading
        if (options.text)
            $print(`\n#== ${options.text} ==#`);
        // output strings as they are, everything else as indented JSON
        $print(typeof input === "string" ? input : JSON.stringify(input, null, 2));
    }
    return input;
}
