#!/bin/tjsh

import * as bf from "bf";

// usage: bf-env <key> [default_value] [--no-prefix|-P] [--reload|-r] [--safe|-s]
// print an environment variable - if default_value is not set and the variable does not exist, an error will be
// thrown unless --safe is set
const { flags: $flags, positional: [$key, $default] } = bf.parseArgs(bf.sys.args, { "no-prefix": "P", reload: "r", safe: "s" });
if ($key === undefined) bf.write.error("bf-env", "Usage: bf-env <key> [default_value] [--no-prefix|-P] [--reload|-r] [--safe|-s]");

// reload if required
if ($flags.has("reload")) await bf.env.load();

// print value
const $value = bf.env.get($key, { add_prefix: !$flags.has("no-prefix"), default_value: $default, safe: $flags.has("safe") });
await bf.sys.print($value);
