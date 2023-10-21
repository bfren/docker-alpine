FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save build and version information to log
    echo "Arch: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.15.10" >> /log && \
    echo "Nushell: 0.86.0" >> /log

FROM ghcr.io/bfren/nushell:0.86.0-alpine as nushell

FROM alpine:3.15.10
COPY --from=build /log /etc/bf/BUILD
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
    # path to bf configuration
    BF_ETC=/etc/bf \
    # upgrade packages during installation
    BF_UPGRADE_PACKAGES=0

ENV \
    # add bf executables to PATH
    PATH=${BF_BIN}:${PATH}

COPY ./overlay /
COPY ./3.15/overlay /

RUN chmod +x /preinstall && /preinstall
RUN bf-install

ENTRYPOINT [ "/init" ]
