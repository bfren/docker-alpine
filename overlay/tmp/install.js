#!/bin/tjsh
import * as bf from "bf";
// upgrade to current versions of packages
if (bf.env.check("UPGRADE_PACKAGES")) {
    bf.write.info("", "Upgrading packages.");
    await bf.pkg.upgrade();
}
// link bf-withenv for easier use in shell scripts
bf.write.info("", "Creating withenv link.");
await bf.handle(["ln", "/usr/bin/bf/bf-withenv", "/bin/withenv"]);
// make esh script executable
await bf.ch.ch(["/usr/local/bin/esh"], { mode: "0555" });
// set timezone
await bf.tz.tz(bf.env.get("TZ"));
