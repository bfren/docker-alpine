import * as sys from "./sys.js";
import * as write from "./write.js";
/**
 * Download a URL and either return or save contents.
 *
 * @param url URL to download.
 * @param destination Optional destination (including filename) - if not set the file will be saved to the current
 * working directory, using the name of the file being downloaded.
 * @param options Function options.
 * @returns The contents (if return is set), otherwise the path to the saved file.
 */
export async function download(url, destination, options = {}) {
    const $response = await fetch(url);
    if (!$response.ok)
        write.error("http/download", "Unable to download %s: %d.", url, $response.status);
    // return contents as text
    if (options.return)
        return $response.text();
    // use destination if set, otherwise get the name of the file being downloaded and save to cwd
    const $file = destination || sys.path.basename(new URL(url).pathname);
    await sys.writeFile($file, new Uint8Array(await $response.arrayBuffer()));
    return $file;
}
/**
 * Return the status code for a given URL - redirects are not followed, and 400 is returned if the request fails.
 *
 * @param url URL to request.
 * @returns HTTP status code.
 */
export async function getStatus(url) {
    try {
        return (await fetch(url, { redirect: "manual" })).status;
    }
    catch {
        return 400;
    }
}
/**
 * Test a URL and return whether or not it gives a success (or redirect) HTTP status code.
 *
 * @param url URL to test.
 */
export async function test(url) {
    const $status = await getStatus(url);
    return $status >= 200 && $status <= 399;
}
