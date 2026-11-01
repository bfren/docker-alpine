#!/bin/tjsh
import * as bf from "bf";
// usage: bf-env-check <key> [--no-prefix|-P] [--reload|-r]
// exits 0 if <key> exists in the environment and is equal to 1, otherwise 1
const { flags: $flags, positional: [$key] } = bf.parseArgs(bf.sys.args, { "no-prefix": "P", reload: "r" });
if ($key === undefined)
    bf.write.error("bf-env-check", "Usage: bf-env-check <key> [--no-prefix|-P] [--reload|-r]");
// reload if required
if ($flags.has("reload"))
    await bf.env.load();
// execute check
bf.sys.exit(bf.env.check($key, !$flags.has("no-prefix")) ? 0 : 1);
