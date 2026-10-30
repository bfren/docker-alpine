/**
 * Split multiline input string into an array of lines.
 *
 * @param input Multiline input string.
 * @returns Array of lines.
 */
export function splitLines(input: string): Array<string> {
    return input.split(/\r?\n/);
}