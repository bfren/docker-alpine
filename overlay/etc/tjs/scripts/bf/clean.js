import * as env from "./env.js";
import * as fs from "./fs.js";
import { handle } from "./handle.js";
import * as sys from "./sys.js";
import * as write from "./write.js";
/**
 * Clean temporary directories, caches and installation files.
 *
 * @param options Function options.
 */
export async function clean(options = {}) {
    const { caches = ["/var/cache/apk/*"], tmpdirs = ["/tmp/*"], root = "/" } = options;
    // delete caches and temporary files - globs end /* so the directories themselves are kept
    const $globs = [...caches, ...tmpdirs];
    if ($globs.length > 0) {
        write.debug("clean", "Deleting %s.", $globs.join(", "));
        // shortcut: globs are expanded by sh so must not contain spaces - true of every caller, revisit if that changes
        await handle(["sh", "-c", `rm -rf -- ${$globs.join(" ")}`], { script: "clean" });
    }
    // search for .empty files
    const $files = await fs.findName(root, ".empty");
    if ($files.length > 0) {
        write.debug("clean", "Deleting .empty files.");
        for (const $file of $files)
            await sys.remove($file);
    }
    // remove installation files from published images
    if (env.check("PUBLISHING") && !env.check("TESTING")) {
        write.debug("clean", "Deleting preinstallation script.");
        await sys.remove("/preinstall").catch(() => { });
        write.debug("clean", "Deleting tests module.");
        await sys.remove("/etc/tjs/scripts/tests").catch(() => { });
    }
}
