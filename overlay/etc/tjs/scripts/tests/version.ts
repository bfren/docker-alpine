import { assert } from "../bf/sys.ts";
import { bump, isAtLeast } from "../bf/version.ts";


//======================================================================================================================
// is_at_least
//======================================================================================================================

export function is_at_least__returns_true_when_input_equals_minimum() {
    assert.equal(isAtLeast("1.2.3", "1.2.3"), true);
}

export function is_at_least__returns_true_when_input_is_greater_than_minimum() {
    assert.equal(isAtLeast("1.10.10", "1.10.3"), true);
}

export function is_at_least__returns_false_when_input_is_less_than_minimum() {
    assert.equal(isAtLeast("1.2.3", "1.10.3"), false);
}


//======================================================================================================================
// bump
//======================================================================================================================

export function bump__increments_patch_number() {
    assert.equal(bump("1.2.3"), "1.2.4");
}

export function bump__increments_double_digit_patch_number() {
    assert.equal(bump("1.2.9"), "1.2.10");
}

export function bump__does_not_change_major_or_minor() {
    assert.equal(bump("10.20.0"), "10.20.1");
}
