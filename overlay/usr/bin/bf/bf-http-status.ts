#!/bin/tjsh

import * as bf from "bf";
bf.env.xSet();

// usage: bf-http-status <url>
// print the status code for a given URL
const [$url] = bf.sys.args;
if ($url === undefined) bf.write.error("bf-http-status", "Usage: bf-http-status <url>");
console.log(await bf.http.getStatus($url));
