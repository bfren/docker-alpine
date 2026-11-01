import * as date from "./date.ts";
import * as sys from "./sys.ts";

/**
 * Ansi colour codes for displaying text in difference colours on the terminal (the same codes Nushell uses).
 */
export enum Colour {
    Reset = "\x1b[0m",          // default terminal colour
    Debug = "\x1b[38;5;8m",     // grey
    OK = "\x1b[32m",            // green
    NotOK = "\x1b[1;31m",       // red, bold
    Warn = "\x1b[33m",          // yellow
}

/**
 * Replace printf-style placeholders (%s, %d, %i, %f, %o, %O, %j) in msg with data, in order.
 *
 * @param msg Message containing placeholders.
 * @param data Values to insert.
 * @returns Formatted message.
 */
function sprintf(msg: string, data: any[]): string {
    let $i = 0;
    return msg.replace(/%[sdifoOj%]/g, ($m) => {
        if ($m == "%%") return "%";
        if ($i >= data.length) return $m;
        const $val = data[$i++];
        return typeof $val === "object" ? JSON.stringify($val) : String($val);
    });
}

/**
 * Format a message before outputting it to the console, by adding the [bf] prefix and date.
 * If script and BF_X are both set, BF_X is the prefix and script is the suffix.
 *
 * @param script Script name to add to the text.
 * @param txt The text to format.
 * @param colour The ansi colour of the text.
 * @returns Formatted text.
 */
function fmt(script: string, txt: string, colour: Colour): string {
    // get the name of the base executable
    const $bf_x = (sys.env.BF_X ?? "").trim();

    // use BF_X or the calling script as the prefix
    const $prefix = $bf_x ? `${$bf_x} | ` : (script ? `${script} | ` : "");

    // if script and BF_X are both set, BF_X is the prefix, so use script as the suffix
    const $suffix = (script && $bf_x) ? ` (${script})` : "";

    // add it all together, complete with colours
    return `[bf] ${date.fmt()} | ${$prefix}${colour}${txt}${$suffix}${Colour.Reset}`;
}

/**
 * Output a standard message.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function info(script: string, msg: string, ...data: any[]): void {
    console.log(fmt(script, sprintf(msg, data), Colour.Reset));
}

/**
 * Output a debug-level message (in grey), if BF_DEBUG is 1.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function debug(script: string, msg: string, ...data: any[]): void {
    if (sys.env.BF_DEBUG == "1") console.log(`${Colour.Debug}${fmt(script, sprintf(msg, data), Colour.Debug)}${Colour.Reset}`);
}

/**
 * Output an error-level message and throw it as an error.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function error(script: string, msg: string, ...data: any[]): never {
    const $msg = sprintf(msg, data);
    console.log(fmt(script, $msg, Colour.NotOK));
    throw new Error($msg);
}

/**
 * Output an error-level message (in red).
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function notok(script: string, msg: string, ...data: any[]): void {
    console.log(fmt(script, sprintf(msg, data), Colour.NotOK));
}

/**
 * Output an ok-level message (in green).
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function ok(script: string, msg: string, ...data: any[]): void {
    console.log(fmt(script, sprintf(msg, data), Colour.OK));
}

/**
 * Output a warning-level message (in yellow).
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function warn(script: string, msg: string, ...data: any[]): void {
    console.log(fmt(script, sprintf(msg, data), Colour.Warn));
}
