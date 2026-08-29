import { splitLines } from "./split.ts";

/**
 * Parse an input string with multiple KEY=VAL lines into a dictionary.
 *
 * @param input Input string - each line should contain KEY=VAL.
 * @returns Parsed dictionary object.
 */
export function parseKVP(input: string): Record<string, string> {
    // create dictionary object to hold
    const $dictionary: Record<string, string> = {};

    // split output based on newline, and parse each as KEY=VAL
    splitLines(input).forEach((line: string) => {
        // skip blank lines
        if (!line) return;

        // split on first '=' (variables can include '=' as part of their value)
        const $idx = line.indexOf("=");
        if ($idx == -1) return;

        // get variable key and value, and add to dictionary
        const $key = line.slice(0, $idx).trim();
        const $val = line.slice($idx + 1).trim();
        $dictionary[$key] = $val;
    });

    return $dictionary;
}
