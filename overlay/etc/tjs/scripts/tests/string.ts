import { format, quote } from "../bf/string.ts";
import { assert } from "../bf/sys.ts";
import { randomChars } from "./lib/capture.ts";


//======================================================================================================================
// quote
//======================================================================================================================

export function quote__adds_double_quotes() {
    const $value = randomChars();

    const $result = quote($value);

    assert.equal($result, `"${$value}"`);
}


//======================================================================================================================
// format
//======================================================================================================================

export function format__replaces_placeholders_with_values() {
    const $a = randomChars();
    const $b = randomChars();

    const $result = format("a = {a} b = {b}", { a: $a, b: $b });

    assert.equal($result, `a = ${$a} b = ${$b}`);
}

export function format__throws_error_with_unmatched_placeholders() {
    const $unformatted = "a = {a} b = {b} c = {c}";

    const $result = (() => { try { format($unformatted, { a: randomChars() }); return "no error"; } catch ($e) { return ($e as Error).message; } })();

    assert.equal($result, `${$unformatted} contains unmatched placeholders: {b}, {c}.`);
}

export function format__allows_values_containing_braces() {
    const $result = format("a = {a}", { a: '{"b":1}' });

    assert.equal($result, 'a = {"b":1}');
}

export function format__throws_error_with_unmatched_placeholder_containing_hyphen() {
    const $unformatted = "a = {sub-domain}";

    const $result = (() => { try { format($unformatted, {}); return "no error"; } catch ($e) { return ($e as Error).message; } })();

    assert.equal($result, `${$unformatted} contains unmatched placeholders: {sub-domain}.`);
}
