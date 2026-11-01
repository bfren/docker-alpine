import * as build from "./build.ts";
import * as sys from "./sys.ts";
import * as write from "./write.ts";

/**
 * Directory containing test modules - each exported function in each *.js file is a test.
 */
export const TESTS_DIR = "/etc/tjs/scripts/tests";

/**
 * A discovered test.
 */
interface Test {
    /** '<module> <function>' - e.g. 'write main__writes_text'. */
    name: string;
    /** The test function - it passes if it returns (or resolves) without throwing. */
    fn: () => unknown;
}

/**
 * Options for test() function.
 */
export interface TestOptions {
    /** Ignore HTTP tests (for speed). */
    ignore_http?: boolean;
}

/**
 * Execute tests with the debug switch enabled.
 * Tests run in parallel in this process, so a test that changes sys.env or console must do so synchronously
 * (and restore it), and must never modify shared files.
 *
 * @param options Function options.
 */
export async function test(options: TestOptions = {}): Promise<void> {
    // /test runs without /init, so the stored environment may be empty
    sys.env.PATH = "/usr/bin/bf:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    sys.env.BF_ETC = "/etc/bf";

    const $tests = (await discover()).filter(($t) => !(options.ignore_http && $t.name.startsWith("http")));

    // if no tests are found, warn loudly (but still exit 0) so an empty suite is not mistaken for a pass
    if ($tests.length == 0) {
        write.warn("test/discover", "No tests found - nothing has been tested.");
        return;
    }

    await build.show();
    write.info("test/execute", "Executing %d tests.", $tests.length);

    sys.env.BF_DEBUG = "1";
    sys.env.BF_TESTING = "1";

    // make sure failures are really detected before trusting any results
    await checkCanary();

    // run tests in parallel
    const $results = await Promise.all($tests.map(async ($test) => {
        const $error = await run($test);
        if ($error == null) console.log(`\x1b[1;32mOK\x1b[0m ${$test.name}`);
        return { name: $test.name, error: $error };
    }));

    // if no failures, print success message
    const $failures = $results.filter(($r) => $r.error != null);
    if ($failures.length == 0) {
        write.ok("test/execute", "Executed all %d tests successfully.", $results.length);
        return;
    }

    // output each failure and error message
    for (const $f of $failures) {
        console.log(`\n\x1b[1;31mFAILED\x1b[0m ${$f.name}\n${$f.error}\n`);
    }
    write.error("test/execute", "%d of %d tests failed.", $failures.length, $results.length);
}

/**
 * Import each test module and return every exported function as a test.
 * A module that fails to import throws, so it cannot be silently skipped.
 *
 * @returns Discovered tests, sorted by name.
 */
async function discover(): Promise<Test[]> {
    const $tests: Test[] = [];
    // published images have the tests directory removed
    const $files = await sys.readDir(TESTS_DIR).catch(() => [] as string[]);
    for (const $file of $files.filter(($f) => $f.endsWith(".js"))) {
        const $module = await import(`${TESTS_DIR}/${$file}`);
        const $name = $file.slice(0, -".js".length);
        for (const [$fn, $val] of Object.entries($module)) {
            if (typeof $val === "function") $tests.push({ name: `${$name} ${$fn}`, fn: $val as () => unknown });
        }
    }
    return $tests.sort(($a, $b) => $a.name.localeCompare($b.name));
}

/**
 * Run a test.
 *
 * @param test The test to run.
 * @returns The error (or stack trace) if the test failed, otherwise null.
 */
async function run(test: Test): Promise<string | null> {
    try {
        await test.fn();
        return null;
    } catch ($e) {
        return $e instanceof Error ? ($e.stack ? `${$e.message}\n${$e.stack}` : $e.message) : String($e);
    }
}

/**
 * Make sure the runner really detects failures: a canary that must fail is run in exactly the same way as a test -
 * if it passes (e.g. assertions do not throw), no result can be trusted.
 */
async function checkCanary(): Promise<void> {
    const $error = await run({ name: "canary", fn: () => sys.assert.ok(false, "bf-test-canary") });
    if ($error == null) {
        write.error("test/check_canary", "The test runner is not detecting failures, so results cannot be trusted.");
    }

    write.debug("test/check_canary", "Canary failed as expected - failures are being detected.");
}
