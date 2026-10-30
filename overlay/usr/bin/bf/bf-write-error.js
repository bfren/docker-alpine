#!/bin/tjsh
import * as bf from "bf";
// usage: bf-write-error <text> [script]
const [$text, $script = ""] = bf.sys.args;
if ($text === undefined)
    bf.write.error("bf-write-error", "Usage: bf-write-error <text> [script]");
bf.write.error($script, "%s", $text);
