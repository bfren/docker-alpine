import assert from "tjs:assert";
import * as bf_env from "../bf/env.js";
await bf_env.set("DEBUG", "1");
assert.ok(tjs.version, "tjs.version is defined");
assert.is(bf_env.debug(), true);
