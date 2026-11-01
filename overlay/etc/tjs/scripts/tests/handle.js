import { handle } from "../bf/handle.js";
import { assert } from "../bf/sys.js";
//======================================================================================================================
// main
//======================================================================================================================
/**
 * Returns a command that writes ' out ' to stdout and ' err ' to stderr, then exits with code.
 *
 * @param code Exit code.
 */
function cmd(code) {
    return ["sh", "-c", `echo ' out '; echo ' err ' >&2; exit ${code}`];
}
export async function main__success_returns_trimmed_stdout() {
    const $result = await handle(cmd(0));
    assert.equal($result, "out");
}
export async function main__failure_raises_error_with_code_and_stderr() {
    const $result = await handle(cmd(3)).then(() => "no error", ($e) => $e.message);
    assert.equal($result, "3: err");
}
export async function main__code_only_returns_exit_code_on_success() {
    const $result = await handle(cmd(0), { codeOnly: true });
    assert.equal($result, 0);
}
export async function main__code_only_returns_exit_code_on_failure() {
    const $result = await handle(cmd(3), { codeOnly: true });
    assert.equal($result, 3);
}
export async function main__ignore_error_returns_trimmed_stdout_on_failure() {
    const $result = await handle(cmd(3), { ignoreError: true });
    assert.equal($result, "out");
}
export async function main__ignore_success_returns_nothing_on_success() {
    const $result = await handle(cmd(0), { ignoreSuccess: true });
    assert.equal($result, undefined);
}
export async function main__ignore_success_overrides_on_success() {
    const $result = await handle(cmd(0), { ignoreSuccess: true, onSuccess: () => "called" });
    assert.equal($result, undefined);
}
export async function main__on_success_receives_untrimmed_stdout() {
    const $result = await handle(cmd(0), { onSuccess: ($out) => $out });
    assert.equal($result, " out \n");
}
export async function main__on_success_is_not_called_on_failure() {
    const $result = await handle(cmd(3), { onSuccess: () => "called" }).catch(() => "error");
    assert.equal($result, "error");
}
export async function main__on_failure_receives_code_and_stderr() {
    const $result = await handle(cmd(3), { onFailure: ($code, $err) => ({ code: $code, err: $err }) });
    assert.deepEqual($result, { code: 3, err: " err \n" });
}
export async function main__on_failure_is_not_called_on_success() {
    const $result = await handle(cmd(0), { onFailure: () => "called" });
    assert.equal($result, "out");
}
