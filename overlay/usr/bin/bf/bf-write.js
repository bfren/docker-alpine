#!/bin/tjsh
import * as bf from "bf";
// usage: bf-write <text> [script]
const [$text, $script = ""] = bf.sys.args;
if ($text === undefined)
    bf.write.error("bf-write", "Usage: bf-write <text> [script]");
bf.write.info($script, "%s", $text);
