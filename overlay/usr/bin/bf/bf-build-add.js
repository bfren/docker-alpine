#!/bin/tjsh
import * as bf from "bf";
await bf.env.load({ set_executable: true });
// usage: bf-build-add <key> <value>
// add an entry to the build log
const [$key, $value] = bf.sys.args;
if ($key === undefined || $value === undefined)
    bf.write.error("bf-build-add", "Usage: bf-build-add <key> <value>");
await bf.build.add($key, $value);
