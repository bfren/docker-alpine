import * as env from "./env.js";
import * as exec from "./exec.js";
import * as fs from "./fs.js";
import * as _ from "./util.js";
import * as write from "./write.js";
/**
 * Filesystem object type for using with find executable.
 */
export var FindType;
(function (FindType) {
    FindType["Unknown"] = "";
    FindType["File"] = "f";
    FindType["Directory"] = "d";
    FindType["Symlink"] = "l";
})(FindType || (FindType = {}));
const DEFAULT_APPLY_OPTIONS = {};
export async function apply(path, owner, options = {}) {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_APPLY_OPTIONS, ...options };
    // grab all promises to run at once
    const $actions = [];
    // apply ownership
    $actions.push(chownR(path, owner));
    // apply permissions
    if (_.notEmpty($opt.fmode))
        $actions.push(chmodFindType(path, FindType.File, $opt.fmode));
    if (_.notEmpty($opt.dmode))
        $actions.push(chmodFindType(path, FindType.Directory, $opt.dmode));
    // run actions and return
    const $result = await Promise.all($actions);
    return $result.every(r => r);
}
export async function applyFile(file) {
    // get path
    const $fileInfo = await fs.pathInfo(file);
    const $path = $fileInfo.isFile ? $fileInfo.path : `${env.get("ETC_CH_D")}/${file}`;
    const $pathInfo = await fs.pathInfo($path);
    // ensure permissions file exists
    if (!$pathInfo.isFile)
        throw write.error("ch.applyFile", "Unable to find file '%s'.", file);
    // split by row and build array of actions
    write.info("ch.applyFile", "Applying %s.", $pathInfo.path);
    const $actions = [];
    _.splitLines(await fs.read($pathInfo)).forEach(line => {
        const $parts = line.split(" ");
        if ($parts.length == 2) {
            $actions.push(apply($parts[0], $parts[1]));
        }
        else if ($parts.length == 3) {
            $actions.push(apply($parts[0], $parts[1], { fmode: $parts[2] }));
        }
        else if ($parts.length == 4) {
            $actions.push(apply($parts[0], $parts[1], { fmode: $parts[2], dmode: $parts[3] }));
        }
    });
    // run actions and return
    const $result = await Promise.all($actions);
    return $result.every(r => r);
}
export async function chmodFindType(base, type, mode) {
    // use system chmod
    const $result = await exec.run("find", [base, "-type", type.toString(), "-exec", "chmod", mode]);
    // log errors
    if ($result.status != 0)
        write.error("ch.chmodFindType", $result.stderr);
    // return result
    return $result.status == 0;
}
export async function chmodR(path, mode) {
    // use system chmod
    const $result = await exec.run("chmod", ["-R", mode, path]);
    // log errors
    if ($result.status != 0)
        write.error("ch.chmodR", $result.stderr);
    // return result
    return $result.status == 0;
}
export async function chownFindType(base, type, mode) {
    // use system chmod
    const $result = await exec.run("find", [base, "-type", type.toString(), "-exec", "chown", mode]);
    // log errors
    if ($result.status != 0)
        write.error("ch.chmodFindType", $result.stderr);
    // return result
    return $result.status == 0;
}
export async function chownR(path, owner) {
    // use system chown
    const $result = await exec.run("chown", ["-R", owner, path]);
    // log errors
    if ($result.status != 0)
        write.error("ch.chownR", $result.stderr);
    // return result
    return $result.status == 0;
}
function parseFindType(val) {
    const $reverse = Object.values(FindType).find((v) => v == val);
    return _.empty($reverse) ? FindType.Unknown : $reverse;
}
