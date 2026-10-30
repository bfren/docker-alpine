import { dump } from "../bf/dump.ts";
import { assert } from "../bf/sys.ts";
import { capture, randomChars } from "./lib/capture.ts";


//======================================================================================================================
// main
//======================================================================================================================

export function main__returns_original_input() {
    const $input = randomChars();

    let $result: string | undefined;
    capture(() => { $result = dump($input); });

    assert.equal($result, $input);
}

export function main__outputs_header() {
    const $header = randomChars();
    const $input = randomChars();

    const $result = capture(() => dump($input, { always: true, text: $header }));

    assert.ok($result.stdout.includes(`#== ${$header} ==#`));
}

export function main__outputs_input() {
    const $input = randomChars();

    const $result = capture(() => dump($input, { always: true }));

    assert.ok($result.stdout.includes($input));
}

export function main__uses_stderr() {
    const $input = randomChars();

    const $result = capture(() => dump($input, { always: true, stderr: true }));

    assert.ok($result.stderr.includes($input));
}
