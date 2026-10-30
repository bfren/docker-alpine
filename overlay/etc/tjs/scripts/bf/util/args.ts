import * as write from "../write.ts";

/**
 * Parsed command-line arguments.
 */
export interface ParsedArgs {
    /** Long names of the flags that were set. */
    flags: Set<string>;
    /** Everything that is not a flag, in order. */
    positional: string[];
}

/**
 * Split command-line arguments into flags (--long or -s, short flags may be combined e.g. -Ps) and positional
 * arguments - an unknown flag throws an error.
 *
 * @param args Command-line arguments.
 * @param flags Known flags - long name (without --) to short name (without -).
 * @returns Parsed arguments.
 */
export function parseArgs(args: string[], flags: Record<string, string>): ParsedArgs {
    const $short = Object.fromEntries(Object.entries(flags).map(([$long, $s]) => [$s, $long]));
    const $parsed: ParsedArgs = { flags: new Set(), positional: [] };

    for (const $arg of args) {
        if ($arg.startsWith("--") && $arg.slice(2) in flags) $parsed.flags.add($arg.slice(2));
        else if (/^-[a-zA-Z]+$/.test($arg) && [...$arg.slice(1)].every(($c) => $c in $short)) {
            for (const $c of $arg.slice(1)) $parsed.flags.add($short[$c]);
        }
        else if ($arg.startsWith("-") && $arg != "-") write.error("args", "Unknown flag '%s'.", $arg);
        else $parsed.positional.push($arg);
    }

    return $parsed;
}
