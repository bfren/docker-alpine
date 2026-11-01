#!/bin/tjsh

import * as bf from "bf";
await bf.env.load({ set_executable: true });

// output information about the current image including name and version
await bf.image();
