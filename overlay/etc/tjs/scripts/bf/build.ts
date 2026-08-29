import * as env from "./env.ts";
import * as fs from "./fs.ts";
import * as _ from "./util.ts";

/**
 * The name of the file containing information about the image.
 */
export const BUILD_FILE = "BUILD";

/**
 * Display build information about the image.
 */
export async function show(): Promise<void> {
    // read and parse build info file
    const $build = await fs.read(`${env.get("ETC")}/${BUILD_FILE}`);
    const $info = _.parseKVP($build);

    // display as Markdown table
    console.log(_.toTable($info));
}