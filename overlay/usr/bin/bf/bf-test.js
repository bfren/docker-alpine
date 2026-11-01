#!/bin/tjsh
import * as bf from "bf";
// usage: bf-test [--ignore-http|-H]
const { flags: $flags } = bf.parseArgs(bf.sys.args, { "ignore-http": "H" });
await bf.test({ ignore_http: $flags.has("ignore-http") });
