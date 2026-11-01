import * as sys from "./sys.js";
import * as write from "./write.js";
/**
 * Set BF_X to the name of the script and then execute it, with output passed straight through - an error is thrown
 * if the script fails. The script is run with tjs directly rather than via tjsh, which would replace BF_X.
 *
 * @param path Absolute path to the file to execute.
 */
export async function x(path) {
    // if the file path is long, use the filename instead of the full path
    const $name = path.length > 15 ? sys.path.basename(path) : path;
    write.debug("x", "Executing script: %s.", path);
    // set X variable and execute script
    const $code = await sys.run(["tjs", "run", "--import-map", "/etc/tjs/map.json", path], { ...sys.env, BF_X: $name });
    if ($code != 0)
        write.error("x", "%s exited with code %d.", path, $code);
}
