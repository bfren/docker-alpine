#!/bin/tjsh

import * as bf from "bf";
await bf.env.load({ set_executable: true });

// parse and display information from the build log
await bf.build.show();
