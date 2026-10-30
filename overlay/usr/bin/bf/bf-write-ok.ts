#!/bin/tjsh

import * as bf from "bf";

// usage: bf-write-ok <text> [script]
const [$text, $script = ""] = bf.sys.args;
if ($text === undefined) bf.write.error("bf-write-ok", "Usage: bf-write-ok <text> [script]");
bf.write.ok($script, "%s", $text);
