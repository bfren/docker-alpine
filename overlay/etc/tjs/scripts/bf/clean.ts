import * as env from "./env.ts";
import * as fs from "./fs.ts";
import { handle } from "./handle.ts";
import * as sys from "./sys.ts";
import * as write from "./write.ts";

/**
 * Options for clean() function.
 */
export interface CleanOptions {
    /** Globs of cache files to delete. */
    caches?: string[];
    /** Globs of temporary files to delete. */
    tmpdirs?: string[];
    /** Directory to search for .empty files. */
    root?: string;
    /** Directories to search for TypeScript sources - only the compiled .js files are needed at runtime. */
    sources?: string[];
}

/**
 * Clean temporary directories, caches and installation files.
 *
 * @param options Function options.
 */
export async function clean(options: CleanOptions = {}): Promise<void> {
    const { caches = ["/var/cache/apk/*"], tmpdirs = ["/tmp/*"], root = "/", sources = ["/etc/tjs", "/usr/bin/bf"] } = options;

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
        for (const $file of $files) await sys.remove($file);
    }

    // delete TypeScript sources
    const $sources = (await Promise.all(sources.map(($s) => fs.findName($s, "*.ts")))).flat();
    if ($sources.length > 0) {
        write.debug("clean", "Deleting TypeScript sources.");
        for (const $file of $sources) await sys.remove($file);
    }

    // remove installation files from published images
    if (env.check("PUBLISHING") && !env.check("TESTING")) {
        write.debug("clean", "Deleting preinstallation script.");
        await sys.remove("/preinstall").catch(() => { });

        write.debug("clean", "Deleting tests module.");
        await sys.remove("/etc/tjs/scripts/tests").catch(() => { });
    }
}
