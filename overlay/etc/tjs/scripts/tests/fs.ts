import { findName, findType, findTypeAcc, isDir, isNotDir, isNotFile, isNotSymlink, makeTempDir, read } from "../bf/fs.ts";
import { handle } from "../bf/handle.ts";
import * as sys from "../bf/sys.ts";
import { randomChars, runScript } from "./lib/capture.ts";

const { assert } = sys;

/** Run a shell command and return trimmed stdout. */
async function sh(cmd: string): Promise<string> {
    return await handle(["sh", "-c", cmd]) ?? "";
}

/** Make a temporary file (in dir if set) and return its path. */
function mktemp(dir?: string): Promise<string> {
    return sh(dir ? `mktemp -p ${dir}` : "mktemp");
}

/** Make a symlink to target and return its path. */
async function symlink(target: string): Promise<string> {
    const $link = `/tmp/${randomChars()}`;
    await sh(`ln -s ${target} ${$link}`);
    return $link;
}


//======================================================================================================================
// find_name - searches its own temporary directory rather than /tmp, so other tests' temporary files cannot interfere
//======================================================================================================================

export async function find_name__returns_list_of_matching_files() {
    const $tmp = await makeTempDir();
    const $file = await mktemp($tmp);
    for (let $i = 0; $i < 3; $i++) await sh(`cp ${$file} $(mktemp -d -p ${$tmp})`);

    const $result = await findName($tmp, sys.path.basename($file));

    assert.equal($result.length, 4, "the original file plus three copies");
}

export async function find_name__returns_list_of_matching_directories() {
    const $tmp = await makeTempDir();
    const $dir0 = await sh(`mktemp -d -p ${$tmp}`);
    for (let $i = 0; $i < 2; $i++) await sh(`cp -r ${$dir0} $(mktemp -d -p ${$tmp})`);

    const $result = await findName($tmp, sys.path.basename($dir0), "d");

    assert.equal($result.length, 3);
}

export async function find_name__returns_empty_list_when_no_match() {
    const $result = await findName("/", randomChars());

    assert.equal($result.length, 0);
}

export async function find_name__returns_empty_list_when_wrong_directory() {
    const $file = await mktemp();
    for (let $i = 0; $i < 3; $i++) await sh(`cp ${$file} ${await makeTempDir()}`);

    const $result = await findName("/etc", sys.path.basename($file));

    assert.equal($result.length, 0);
}


//======================================================================================================================
// find_type
//======================================================================================================================

export async function find_type__returns_list_of_directories() {
    const $tmp = await makeTempDir();
    for (let $i = 0; $i < 3; $i++) await sh(`mktemp -d -p ${$tmp}`);

    const $result = await findType($tmp, "d");

    assert.equal($result.length, 4);
}

export async function find_type__returns_list_of_files() {
    const $tmp = await makeTempDir();
    const $file = await mktemp($tmp);
    for (let $i = 0; $i < 3; $i++) await sh(`cp ${$file} $(mktemp -d -p ${$tmp})`);

    const $result = await findType($tmp, "f");

    assert.equal($result.length, 4);
}


//======================================================================================================================
// find_type_acc
//======================================================================================================================

export async function find_type_acc__returns_list_of_directories() {
    const [$tmp0, $tmp1] = [await makeTempDir(), await makeTempDir()];
    const $dir = await sh("mktemp -d");
    await sh(`cp -r ${$dir} ${$tmp0} && cp -r ${$dir} ${$tmp1}`);

    const $result = await findTypeAcc([$tmp0, $tmp1], "d");

    assert.equal($result.length, 4);
}

export async function find_type_acc__returns_list_of_files() {
    const [$tmp0, $tmp1] = [await makeTempDir(), await makeTempDir()];
    const $file = await mktemp();
    await sh(`cp ${$file} ${$tmp0} && cp ${$file} ${$tmp1}`);

    const $result = await findTypeAcc([$tmp0, $tmp1], "f");

    assert.equal($result.length, 2);
}


//======================================================================================================================
// is_dir
//======================================================================================================================

export async function is_dir__input_is_dir_returns_true() {
    assert.equal(await isDir(await sh("mktemp -d")), true);
}

export async function is_dir__input_is_file_returns_false() {
    assert.equal(await isDir(await mktemp()), false);
}

export async function is_dir__input_is_symlink_to_dir_returns_false() {
    assert.equal(await isDir(await symlink(await sh("mktemp -d"))), false);
}

export async function is_dir__input_does_not_exist_returns_false() {
    assert.equal(await isDir(`/tmp/${randomChars()}`), false);
}


//======================================================================================================================
// is_not_dir
//======================================================================================================================

export async function is_not_dir__input_is_dir_returns_false() {
    assert.equal(await isNotDir(await sh("mktemp -d")), false);
}

export async function is_not_dir__input_is_file_returns_true() {
    assert.equal(await isNotDir(await mktemp()), true);
}

export async function is_not_dir__input_is_symlink_returns_true() {
    assert.equal(await isNotDir(await symlink(await mktemp())), true);
}


//======================================================================================================================
// is_not_file
//======================================================================================================================

export async function is_not_file__input_is_dir_returns_true() {
    assert.equal(await isNotFile(await sh("mktemp -d")), true);
}

export async function is_not_file__input_is_file_returns_false() {
    assert.equal(await isNotFile(await mktemp()), false);
}

export async function is_not_file__input_is_symlink_returns_true() {
    assert.equal(await isNotFile(await symlink(await mktemp())), true);
}


//======================================================================================================================
// is_not_symlink
//======================================================================================================================

export async function is_not_symlink__input_is_dir_returns_true() {
    assert.equal(await isNotSymlink(await sh("mktemp -d")), true);
}

export async function is_not_symlink__input_is_file_returns_true() {
    assert.equal(await isNotSymlink(await mktemp()), true);
}

export async function is_not_symlink__input_is_symlink_returns_false() {
    assert.equal(await isNotSymlink(await symlink(await mktemp())), false);
}


//======================================================================================================================
// make_temp_dir
//======================================================================================================================

export async function make_temp_dir__creates_dir() {
    assert.equal(await isDir(await makeTempDir()), true);
}

export async function make_temp_dir__creates_dir_in_tmp() {
    assert.equal(sys.path.dirname(await makeTempDir()), "/tmp");
}

export async function make_temp_dir__creates_dir_in_working_directory() {
    // the working directory is shared by every test in this process, so change it in a child process
    const $cwd = await sh("mktemp -d");

    const $result = await runScript(
        `import * as bf from "bf";\nbf.sys.chdir("${$cwd}");\nconsole.log(await bf.fs.makeTempDir({ local: true }));\n`,
        { PATH: sys.env.PATH }
    );

    assert.equal(sys.path.dirname($result), $cwd);
}


//======================================================================================================================
// read
//======================================================================================================================

export async function read__expands_virtual_filename() {
    // the working directory is shared by every test in this process, so change it in a child process
    const $file = await mktemp();
    const $contents = randomChars();
    await sys.writeTextFile($file, $contents);

    const $result = await runScript(
        `import * as bf from "bf";\nbf.sys.chdir("${sys.path.dirname($file)}");\nconsole.log(await bf.fs.read("${sys.path.basename($file)}"));\n`
    );

    assert.equal($result, $contents);
}

export async function read__file_does_not_exist_throws_error() {
    const $file = `/tmp/${randomChars()}`;

    const $result = await read($file).then(() => "no error", ($e: Error) => $e.message);

    assert.equal($result, `File does not exist: ${$file}.`);
}

export async function read__file_does_not_exist_with_quiet_returns_empty() {
    const $result = await read(`/tmp/${randomChars()}`, { quiet: true });

    assert.equal($result, "");
}

export async function read__returns_trimmed_file_contents() {
    const $file = await mktemp();
    const $contents = randomChars();
    await sys.writeTextFile($file, ` ${$contents} `);

    const $result = await read($file);

    assert.equal($result, $contents);
}
