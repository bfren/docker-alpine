# Alpine

![GitHub release (latest by date)](https://img.shields.io/github/v/release/bfren/docker-alpine) ![Docker Pulls](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fpulls%2Falpine) ![Docker Image Size](https://img.shields.io/endpoint?url=https%3A%2F%2Fbfren.dev%2Fdocker%2Fsize%2Falpine) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/bfren/docker-alpine/build.yml?branch=main)

[Docker Hub](https://hub.docker.com/r/bfren/alpine) - [Quay.io](https://quay.io/repository/bfren/alpine) - [bfren ecosystem](https://github.com/bfren/docker)

## Introduction

This is the foundation of the [bfren ecosystem](https://github.com/bfren/docker) - every other image is built on it, either directly or through [Alpine + S6](https://github.com/bfren/docker-alpine-s6).

It is [Alpine Linux](https://alpinelinux.org) with:

* [txiki.js](https://github.com/saghul/txiki.js), a small JavaScript runtime, and the `bf` module, for writing installation and start-up scripts in plain JavaScript with real error handling
* a custom build of [BusyBox](https://busybox.net) with its default config plus relevant patches from Alpine Linux
* a static build of [figlet](https://github.com/bfren/figlet), used for the start-up banner
* a standard build step (`bf-install`) so every image is installed and cleaned up the same way
* a shared environment store, so every script sees the same variables
* helper executables for shell scripts, and [esh](https://github.com/jirutka/esh) for templates

Use it as the `FROM` line for images that run a single command or tool. For images that run a long-lived service, use [Alpine + S6](https://github.com/bfren/docker-alpine-s6) instead.

## Quickstart

```plain
my-image/
├── Dockerfile
└── overlay/
    └── tmp/
        └── install.js
```

`Dockerfile`:

```dockerfile
FROM quay.io/bfren/alpine:alpine3.24-5.0

ARG BF_IMAGE=my-image
ARG BF_VERSION=1.0.0

COPY ./overlay /
RUN bf-install
```

`overlay/tmp/install.js` - your installation script, run by `bf-install`:

```js
import * as bf from "bf";

await bf.pkg.install(["curl", "jq"]);
bf.write.ok("install", "my-image installed.");
```

Build it and open a shell:

```sh
docker build -t my-image . && docker run --rm -it my-image sh
```

Inside the container, `bf-image` shows the image name and version.

## Features

* 🐧 Alpine 3.20 to 3.24 - choose with the image tag
* 📜 txiki.js, with the `bf` module available to every script
* 🧱 `bf-install` - one standard build step for every image
* 🌍 Container environment saved at start-up and available to every script
* 🛠️ Helper executables (`bf-env`, `bf-write`, `bf-wget`, …) for shell scripts
* 📝 [esh](https://github.com/jirutka/esh) for generating files from templates
* 🕐 Timezone set to `Europe/London`
* 🧪 Built-in test runner that checks failures are really detected

## Tags

Images are published to Docker Hub (`bfren/alpine`) and Quay.io (`quay.io/bfren/alpine`) for `linux/amd64`, `linux/arm/v7` and `linux/arm64`.

| Tag                           | Example              | Use when                                              |
| ----------------------------- | -------------------- | ----------------------------------------------------- |
| `alpineX.Y`                   | `alpine3.24`         | You want the latest image for an Alpine version       |
| `alpineX.Y-MAJOR`             | `alpine3.24-5`       | You want updates, but not breaking changes            |
| `alpineX.Y-MINOR`             | `alpine3.24-5.0`     | You want fixes only - **recommended for building on** |
| `alpineX.Y-VERSION`           | `alpine3.24-5.0.0`   | You want to pin this image exactly                    |
| `alpineX.Y.Z`                 | `alpine3.24.3`       | You want an exact Alpine release                      |
| `alpineX.Y.Z-VERSION`         | `alpine3.24.3-5.0.0` | You want to pin both                                  |
| `latest`, `5`, `5.0`, `5.0.0` |                      | As above, on the newest Alpine version                |

| Alpine | Security support ends |
| ------ | --------------------- |
| 3.24   | 2028-06-01            |
| 3.23   | 2027-11-01            |
| 3.22   | 2027-05-01            |
| 3.21   | 2026-11-01            |
| 3.20   | ended 2026-04-01      |

Images for unsupported Alpine versions are still built, but no longer receive Alpine security fixes - avoid them for anything new.

## Configuration

### Environment Variables

| Variable   | Values   | Description                             | Default |
| ---------- | -------- | --------------------------------------- | ------- |
| `BF_DEBUG` | `0`, `1` | Show detailed output from `bf` scripts. | `0`     |

### Build Arguments

| Argument        | Description                                                                   |
| --------------- | ----------------------------------------------------------------------------- |
| `BF_IMAGE`      | **Required by `bf-install`.** The image name, saved to `/etc/bf/IMAGE`.       |
| `BF_VERSION`    | **Required by `bf-install`.** The image version, saved to `/etc/bf/VERSION`.  |
| `BF_PUBLISHING` | Set to `1` for release builds - removes the test files and preinstall script. |

## How It Works

### Building

`bf-install` is the standard last step of every bfren Dockerfile. It:

1. shows the build log and `BF_` variables
2. sets standard permissions
3. runs `/tmp/install.js` if it exists - put your own installation steps there
4. saves the image name and version
5. cleans up `/tmp`, the package cache and placeholder `.empty` files

### Starting

`/init` is the entrypoint. It saves the container's environment - including anything you pass with `-e` - to `/etc/bf/env.d`, then runs your command.

### Scripts

Scripts are JavaScript modules run by txiki.js. Executables start with `#!/bin/tjsh`, which runs the script with the `bf` module available and the saved environment from `/etc/bf/env.d` added to the caller's environment. For example, after `docker run -e BF_GREETING=hello …`:

```js
#!/bin/tjsh

import * as bf from "bf";

bf.write.info("greet", "The greeting is %s.", bf.env.get("GREETING"));
```

`bf.env.get("GREETING")` reads `BF_GREETING` - the `BF_` prefix is added for you. `await bf.env.set("NAME", "value")` saves `BF_NAME` for every later script.

Shell scripts can run commands with a *clean* environment loaded from `/etc/bf/env.d` using `withenv`, e.g. `withenv my-command`.

### The `bf` module

| Function / namespace | Use                                                                          |
| -------------------- | ---------------------------------------------------------------------------- |
| `bf.build`           | Read the image build log, and add entries to it                              |
| `bf.ch`              | Set ownership and permissions on files and directories                       |
| `bf.clean()`         | Remove temporary files, package caches and `.empty` placeholders             |
| `bf.del`             | Delete files or directories older than a given age                           |
| `bf.dump()`          | Print a value when debug output is enabled, then pass it on                  |
| `bf.env`             | Get, set, check, load and store environment variables                        |
| `bf.esh()`           | Generate output from an esh template                                         |
| `bf.fs`              | Read files, find paths and make temporary directories                        |
| `bf.handle()`        | Run an external command and turn failures into errors                        |
| `bf.http`            | Download files and check URLs                                                |
| `bf.image()`         | Show a banner with the image name, version and Alpine version                |
| `bf.install()`       | Run the standard image installation (used by `bf-install`)                   |
| `bf.pkg`             | Install, remove and upgrade Alpine packages                                  |
| `bf.string`          | Quote strings and fill `{placeholder}` templates                             |
| `bf.sys`             | The txiki.js runtime - files, processes and environment                      |
| `bf.test()`          | Discover and run the tests in `/etc/tjs/scripts/tests`                       |
| `bf.tz`              | Get and set the timezone                                                     |
| `bf.user`            | Add users and groups                                                         |
| `bf.version`         | Compare and bump version numbers                                             |
| `bf.write`           | Write timestamped, coloured output (`ok`, `notok`, `warn`, `error`, `debug`) |
| `bf.x()`             | Run a script with `BF_X` set to its name, so its output is labelled          |

Each function is documented in its source file in `/etc/tjs/scripts/bf`. Only `bf.sys` uses the txiki.js runtime directly, so scripts that use `bf` can move to another runtime by replacing that one module.

Many of these have executable helpers on the `PATH` for shell scripts. For example, `bf-image` runs `bf.image()`, which is handy with `docker exec`. Check out `overlay/usr/bin/bf` for the complete list.

## Testing

`/test` runs the tests in `/etc/tjs/scripts/tests` (`/test-without-http` skips tests that need the internet). Before running, it checks that failing tests are really detected, and fails if they aren't. Tests are removed from published images, so run them on your own builds.

```sh
./test.nu        # builds the image and runs /test
./test.nu --all  # every version, in parallel
```

## Troubleshooting

### The container exits straight away

The image has no default command. Give it one, e.g. `docker run --rm -it bfren/alpine sh`.

### The build fails with "Unable to get environment variable BF_IMAGE"

`bf-install` needs the `BF_IMAGE` and `BF_VERSION` build arguments. Declare them in your Dockerfile (see [Quickstart](#quickstart)) or pass them with `--build-arg`.

### Setting `BF_TZ` does nothing

In this image the timezone is set when the image is built. Call `await bf.tz.set("Europe/Paris")` (for example) in your `/tmp/install.js`, or use [Alpine + S6](https://github.com/bfren/docker-alpine-s6), which applies `BF_TZ` every time the container starts.

### `/test` says no tests were found

Published images have their tests removed. Build the image yourself without `BF_PUBLISHING=1`.

## FAQs

### Should I use this image or Alpine + S6?

Use this one for images that run a single command - a CLI tool, a build step, PHP scripts. Use [Alpine + S6](https://github.com/bfren/docker-alpine-s6) for long-running services, especially if they need scheduled tasks or start-up checks.

### Why save the environment at start-up?

Anything that doesn't inherit the container's environment - scheduled tasks, other users, scripts run with a clean environment - can still read the same values from `/etc/bf/env.d`.

### Why txiki.js?

JavaScript is stable - scripts written today will keep working without changes - and txiki.js is small enough for an Alpine image. Because the `bf` module only touches the runtime through `bf.sys`, the scripts are not tied to txiki.js either.

## Licence

> [MIT](https://mit.bfren.dev/2021)

## Copyright

> Copyright (c) 2021-2026 [bfren](https://bfren.dev) (unless otherwise stated)
