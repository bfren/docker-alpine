FROM ghcr.io/bfren/nushell:0.86.0-alpine as nushell

FROM alpine:3.16.7
COPY --from=nushell / /

LABEL org.opencontainers.image.description="Alpine base image with Nushell."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-alpine"

ARG BF_IMAGE
ARG BF_VERSION
ARG NUSHELL_VERSION=0.86.0

ENV \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=0 \
    # path to bf executables
    BF_BIN=/usr/bin/bf \
    # upgrade packages during installation
    BF_UPGRADE_PACKAGES=0

ENV \
    # add bf executables to PATH
    PATH=${BF_BIN}:${PATH}

COPY ./overlay /
COPY ./3.16/overlay /

RUN chmod +x /preinstall && /preinstall
RUN bf-install

ENTRYPOINT [ "/init" ]
