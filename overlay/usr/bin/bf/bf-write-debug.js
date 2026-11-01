#!/bin/tjsh
import * as bf from "bf";
// usage: bf-write-debug <text> [script]
const [$text, $script = ""] = bf.sys.args;
if ($text === undefined)
    bf.write.error("bf-write-debug", "Usage: bf-write-debug <text> [script]");
bf.write.debug($script, "%s", $text);
