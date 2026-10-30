#!/bin/tjsh

import * as bf from "bf";

// usage: bf-write-notok <text> [script]
const [$text, $script = ""] = bf.sys.args;
if ($text === undefined) bf.write.error("bf-write-notok", "Usage: bf-write-notok <text> [script]");
bf.write.notok($script, "%s", $text);
