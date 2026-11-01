import { assert } from "../bf/sys.ts";
import * as write from "../bf/write.ts";
import { capture } from "./lib/capture.ts";


//======================================================================================================================
// main (info)
//======================================================================================================================

export function main__writes_text() {
    const $result = capture(() => write.info("", "hello")).stdout;

    assert.ok($result.includes("hello"), "write does not output text");
    assert.ok($result.startsWith("[bf] "), "write does not output [bf] prefix");
}

export function main__with_script__writes_script_prefix() {
    const $result = capture(() => write.info("my-script", "hello")).stdout;

    assert.ok($result.includes("my-script | hello"), "write does not output script prefix");
}

export function main__with_bf_x__uses_bf_x_as_prefix() {
    const $result = capture(() => write.info("", "hello"), { BF_X: "my-executable" }).stdout;

    assert.ok($result.includes("my-executable | hello"), "write does not use BF_X as prefix");
}

export function main__with_script_and_bf_x__uses_script_as_suffix() {
    const $result = capture(() => write.info("my-script", "hello"), { BF_X: "my-executable" }).stdout;

    assert.ok($result.includes("my-executable | hello (my-script)"), "write does not use script as suffix");
}


//======================================================================================================================
// debug
//======================================================================================================================

export function debug__debug_enabled__writes_text() {
    const $result = capture(() => write.debug("", "hello"), { BF_DEBUG: "1" }).stdout;

    assert.ok($result.includes("hello"), "write debug does not output text when BF_DEBUG is 1");
}

export function debug__debug_not_enabled__writes_nothing() {
    const $result = capture(() => write.debug("", "hello"), { BF_DEBUG: "0" }).stdout;

    assert.equal($result.trim(), "", "write debug outputs text when BF_DEBUG is not 1");
}


//======================================================================================================================
// ok / notok / warn
//======================================================================================================================

export function ok__writes_text() {
    assert.ok(capture(() => write.ok("", "hello")).stdout.includes("hello"));
}

export function notok__writes_text() {
    assert.ok(capture(() => write.notok("", "hello")).stdout.includes("hello"));
}

export function warn__writes_text() {
    assert.ok(capture(() => write.warn("", "hello")).stdout.includes("hello"));
}

export function ok__uses_green() {
    const $result = capture(() => write.ok("", "hello"), {}, true).stdout;

    assert.ok($result.includes(write.Colour.OK), "write ok does not use green");
}

export function notok__uses_red() {
    const $result = capture(() => write.notok("", "hello"), {}, true).stdout;

    assert.ok($result.includes(write.Colour.NotOK), "write notok does not use red");
}

export function warn__uses_yellow() {
    const $result = capture(() => write.warn("", "hello"), {}, true).stdout;

    assert.ok($result.includes(write.Colour.Warn), "write warn does not use yellow");
}


//======================================================================================================================
// error
//======================================================================================================================

export function error__writes_text_and_throws() {
    const $result = capture(() => write.error("", "hello"));

    assert.ok($result.error !== undefined, "write error does not throw");
    assert.ok($result.stdout.includes("hello"), "write error does not output text");
}
