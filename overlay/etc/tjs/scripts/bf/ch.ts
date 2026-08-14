import * as env from "./env.ts";
import * as exec from "./exec.ts";
import * as fs from "./fs.ts";
import * as _ from "./util.ts";
import * as write from "./write.ts";

/**
 * Filesystem object type for using with find executable.
 */
export enum FindType {
    Unknown = "",
    File = "f",
    Directory = "d",
    Symlink = "l"
}

export interface ApplyOptions {
    fmode?: string,
    dmode?: string
}

const DEFAULT_APPLY_OPTIONS: ApplyOptions = {};

export async function apply(path: string, owner: string, options: ApplyOptions = {}): Promise<boolean> {
    // merge default options with whatever has been passed to this function
    const $opt = { ...DEFAULT_APPLY_OPTIONS, ...options };

    // grab all promises to run at once
    const $actions: Promise<boolean>[] = [];

    // apply ownership
    $actions.push(chownR(path, owner));

    // apply permissions
    if (_.notEmpty($opt.fmode)) $actions.push(chmodFindType(path, FindType.File, $opt.fmode));
    if (_.notEmpty($opt.dmode)) $actions.push(chmodFindType(path, FindType.Directory, $opt.dmode));

    // run actions and return
    const $result = await Promise.all($actions);
    return $result.every(r => r);
}

export async function applyFile(file: string): Promise<boolean> {
    // get path
    const $fileInfo = await fs.pathInfo(file);
    const $path = $fileInfo.isFile ? $fileInfo.path : `${env.get("ETC_CH_D")}/${file}`;
    const $pathInfo = await fs.pathInfo($path);

    // ensure permissions file exists
    if (!$pathInfo.isFile) throw write.error("ch.applyFile", "Unable to find file '%s'.", file);

    // split by row and build array of actions
    write.info("ch.applyFile", "Applying %s.", $pathInfo.path);
    const $actions: Promise<boolean>[] = [];
    _.splitLines(await fs.read($pathInfo)).forEach(line => {
        const $parts = line.split(" ");
        if ($parts.length == 2) {
            $actions.push(apply($parts[0], $parts[1]));
        } else if ($parts.length == 3) {
            $actions.push(apply($parts[0], $parts[1], { fmode: $parts[2] }));
        } else if ($parts.length == 4) {
            $actions.push(apply($parts[0], $parts[1], { fmode: $parts[2], dmode: $parts[3] }));
        }
    });

    // run actions and return
    const $result = await Promise.all($actions);
    return $result.every(r => r);
}

export async function chmodFindType(base: string, type: FindType, mode: string): Promise<boolean> {
    // use system chmod
    const $result = await exec.run("find", [base, "-type", type.toString(), "-exec", "chmod", mode]);

    // log errors
    if ($result.status != 0) write.error("ch.chmodFindType", $result.stderr);

    // return result
    return $result.status == 0;
}

export async function chmodR(path: string, mode: string): Promise<boolean> {
    // use system chmod
    const $result = await exec.run("chmod", ["-R", mode, path]);

    // log errors
    if ($result.status != 0) write.error("ch.chmodR", $result.stderr);

    // return result
    return $result.status == 0;
}

export async function chownFindType(base: string, type: FindType, mode: string): Promise<boolean> {
    // use system chmod
    const $result = await exec.run("find", [base, "-type", type.toString(), "-exec", "chown", mode]);

    // log errors
    if ($result.status != 0) write.error("ch.chmodFindType", $result.stderr);

    // return result
    return $result.status == 0;
}

export async function chownR(path: string, owner: string): Promise<boolean> {
    // use system chown
    const $result = await exec.run("chown", ["-R", owner, path]);

    // log errors
    if ($result.status != 0) write.error("ch.chownR", $result.stderr);

    // return result
    return $result.status == 0;
}

function parseFindType(val: string): FindType {
    const $reverse = Object.values(FindType).find((v) => v == val);
    return _.empty($reverse) ? FindType.Unknown : $reverse;
}