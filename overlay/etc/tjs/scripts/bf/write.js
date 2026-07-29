import * as date from "./date.js";
import * as _ from "./util.js";
/**
 * Ansi colour codes for displaying text in difference colours on the terminal.
 */
var Colour;
(function (Colour) {
    Colour["Reset"] = "\u001B[0m";
    Colour["Debug"] = "\u001B[90m";
    Colour["OK"] = "\u001B[32m";
    Colour["NotOK"] = "\u001B[31;1m";
    Colour["Warn"] = "\u001B[33m";
})(Colour || (Colour = {}));
/**
 * Format a message before outputting it to the console, by adding the [bf] prefix and date.
 *
 * @param script Script name to add to the text.
 * @param txt The text to format.
 * @param colour The ansi colour of the text.
 * @returns Formatted text.
 */
function fmt(script, txt, colour) {
    // get the date
    const $date = date.fmt();
    // determine the prefix
    const $bf_x = tjs.env.BF_X;
    const $prefix = _.not_empty(script)
        ? (_.not_empty($bf_x) ? `${$bf_x} | ` : `${script} | `)
        : (_.not_empty($bf_x) ? `${$bf_x} | ` : "");
    // determine the suffix
    const $suffix = (_.not_empty(script) && _.not_empty($bf_x))
        ? ` (${script})`
        : "";
    // add it all together, complete with colours
    return `${colour}[bf] ${$date} | ${$prefix}${txt}${$suffix}${Colour.Reset}`;
}
/**
 * Output a debug-level message.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function debug(script, msg, ...data) {
    if (tjs.env.BF_DEBUG == "1")
        console.log(fmt(script, msg, Colour.Debug), ...data);
}
/**
 * Output an error-level message and return message to be thrown.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 * @returns Error message (to be thrown by calling script).
 */
export function error(script, msg, ...data) {
    const $msg = fmt(script, msg, Colour.NotOK);
    console.error($msg, ...data);
    return $msg;
}
/**
 * Output an information-level message.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function info(script, msg, ...data) {
    console.log(fmt(script, msg, Colour.Reset), ...data);
}
/**
 * Output an error-level message.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function notok(script, msg, ...data) {
    console.error(fmt(script, msg, Colour.NotOK), ...data);
}
/**
 * Output an ok-level message.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function ok(script, msg, ...data) {
    console.log(fmt(script, msg, Colour.OK), ...data);
}
/**
 * Output a warning-level message.
 *
 * @param script Script name to append to the text.
 * @param msg Message to output.
 * @param data Optional data to fill any placeholders in msg.
 */
export function warn(script, msg, ...data) {
    console.log(fmt(script, msg, Colour.Warn), ...data);
}
