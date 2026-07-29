/**
 * Execute an external script, returning status, stderr and stdout.
 *
 * @param path The executable to run.
 * @param args Arguments to add to the executable.
 * @returns Result - including status, stderr and stdout.
 */
export async function run(path: string, args: string[] = []): Promise<Result> {
    // redirect output so it can be captured
    var $p = tjs.spawn([path, ...args], { stderr: "pipe", stdout: "pipe"});
    const [$stderr, $stdout, $result] = await Promise.all([
        new Response($p.stderr).text(),
        new Response($p.stdout).text(),
        await $p.wait()
    ]);

    return { status: $result.exit_status, stderr: $stderr, stdout: $stdout };
}

/**
 * External executable result.
 */
export interface Result {
    /** Exit status. */
    status: number,
    /** Redirected stderr. */
    stderr: string,
    /** Redirected stdout. */
    stdout: string,
}