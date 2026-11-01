#!/bin/tjsh

import * as bf from "bf";

// usage: bf-write-warn <text> [script]
const [$text, $script = ""] = bf.sys.args;
if ($text === undefined) bf.write.error("bf-write-warn", "Usage: bf-write-warn <text> [script]");
bf.write.warn($script, "%s", $text);
