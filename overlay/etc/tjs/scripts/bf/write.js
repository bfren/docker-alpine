import * as date from "./date.js";
import * as sys from "./sys.js";
/**
 * Ansi colour codes for displaying text in difference colours on the terminal (the same codes Nushell uses).
 */
export var Colour;
(function (Colour) {
    Colour["Reset"] = "\u001B[0m";
    Colour["Debug"] = "\u001B[38;5;8m";
    Colour["OK"] = "\u001B[32m";
    Colour["NotOK"] = "\u001B[1;31m";
    Colour["Warn"] = "\u001B[33m";
})(Colour || (Colour = {}));
/**
 * Replace printf-style placeholders (%s, %d, %i, %f, %o, %O, %j) in msg with data, in order.
 *
 * @param msg Message containing placeholders.
 * @param data Values to insert.
 * @returns Formatted message.
 */
function sprintf(msg, data) {
    let $i = 0;
    return msg.replace(/%[sdifoOj%]/g, ($m) => {
        if ($m == "%%")
            return "%";
        if ($i >= data.length)
            return $m;
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
function fmt(script, txt, colour) {
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
export function info(script, msg, ...data) {
    console.log(fmt(script, sprintf(msg, data), Colour.Reset));
}
/**
 * Output a debug-level message (in grey), if BF_DEBUG is 1.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function debug(script, msg, ...data) {
    if (sys.env.BF_DEBUG == "1")
        console.log(`${Colour.Debug}${fmt(script, sprintf(msg, data), Colour.Debug)}${Colour.Reset}`);
}
/**
 * Output an error-level message and throw it as an error.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function error(script, msg, ...data) {
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
export function notok(script, msg, ...data) {
    console.log(fmt(script, sprintf(msg, data), Colour.NotOK));
}
/**
 * Output an ok-level message (in green).
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function ok(script, msg, ...data) {
    console.log(fmt(script, sprintf(msg, data), Colour.OK));
}
/**
 * Output a warning-level message (in yellow).
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function warn(script, msg, ...data) {
    console.log(fmt(script, sprintf(msg, data), Colour.Warn));
}
