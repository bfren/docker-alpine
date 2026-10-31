# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - Unreleased

### Changed

- Build stages now use `quay.io/bfren-bin/alpine` instead of `alpine` from Docker Hub.
- Images are built and published by the shared `bfren/docker` build workflow (`build.yml`), replacing the separate
  `dev.yml` and `publish.yml` workflows.

### Removed

- **Breaking:** images for Alpine 3.15, 3.16, 3.17, 3.18 and 3.19 are no longer built. Supported versions are now
  Alpine 3.20 to 3.24.

### Fixed

- `/etc/nu` is no longer world-writable - files are now `0644` and directories `0755`.
- Tests are no longer copied back into the image after `bf-install` removes them.

[4.0.0]: https://github.com/bfren/docker-alpine/compare/v3.5.3...v4.0.0
