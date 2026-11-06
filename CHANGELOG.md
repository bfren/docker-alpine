# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.1] - 2026-11-06

### Changed

- BusyBox, figlet and Nushell are rebuilt (build `261106.3`) on Alpine 3.24.4. Their versions are unchanged
  (BusyBox 1.37.0, figlet 2.2.5, Nushell 0.116.1), and so are BusyBox's applets and Alpine patches - the patches
  are now stored with the build instead of downloaded during it.

### Deprecated

- Alpine 3.21 reached the end of its support on 2026-11-01. Its images are still built, but no longer receive Alpine
  security fixes - avoid them for anything new.

### Security

- Alpine is updated to 3.21.10, 3.22.8, 3.23.8 and 3.24.4 (3.20 stays at 3.20.10), which include security fixes - see
  the [Alpine release notes](https://alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/).

## [4.0.0] - 2026-11-05

### Changed

- Build stages now use `quay.io/bfren-bin/alpine` instead of `alpine` from Docker Hub.
- Images are built and published by the shared `bfren/docker` build workflow (`build.yml`), replacing the separate
  `dev.yml` and `publish.yml` workflows.
- `bf del old --type` now defaults to `f` (files) - before, leaving it out gave an `Unknown type` error.
- `bf clean` takes its default cache directories from `bf pkg caches`, so an image with another package manager only
  needs its own `pkg.nu`.
- BusyBox applets are installed as symlinks instead of hard links, so they cannot be split from `/bin/busybox` when
  layers are copied or cached.

### Removed

- **Breaking:** images for Alpine 3.15, 3.16, 3.17, 3.18 and 3.19 are no longer built. Supported versions are now
  Alpine 3.20 to 3.24.

### Fixed

- `/etc/nu` is no longer world-writable - files are now `0644` and directories `0755`.
- Tests are no longer copied back into the image after `bf-install` removes them.
- Environment variables with several lines (e.g. a certificate) no longer stop the container starting, or create
  extra variables from their lines. They are saved in full, but loaded as their first line, as before.
- `bf string format` no longer gives an "unmatched placeholders" error when a value contains braces, and no longer
  replaces placeholders inside values it has already inserted. It now uses Nushell's `format pattern`, so braces in
  the template that are not part of a placeholder give an error.
- `bf del old` no longer gives an error when the directory is empty. As before, it never deletes hidden files or
  directories.
- `SHLVL` is no longer saved to the environment store - it is set by the shell running `/init`.

### Security

- The environment store `/etc/bf/env.d` is no longer writable by every user - only root can write to it. Before, any
  user could set a variable such as `PATH` that root scripts then loaded.
- **Breaking:** `bf env set` must now run as root, because only root can write to the environment store.

[4.0.1]: https://github.com/bfren/docker-alpine/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/bfren/docker-alpine/compare/v3.5.3...v4.0.0
