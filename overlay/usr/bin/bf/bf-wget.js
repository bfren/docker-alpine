#!/bin/tjsh
import * as bf from "bf";
bf.env.xSet();
// usage: bf-wget <url> [-O|--destination <path>] [-r|--return]
// download a URL and either print the contents or save them (to the current directory if destination is not set)
const $args = [...bf.sys.args];
const $o = $args.findIndex(($a) => $a == "-O" || $a == "--destination");
const $destination = $o == -1 ? undefined : $args.splice($o, 2)[1];
const { flags: $flags, positional: [$url] } = bf.parseArgs($args, { return: "r" });
if ($url === undefined)
    bf.write.error("bf-wget", "Usage: bf-wget <url> [-O|--destination <path>] [-r|--return]");
console.log(await bf.http.download($url, $destination, { return: $flags.has("return") }));
