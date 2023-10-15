FROM alpine:3.15.10

LABEL org.opencontainers.image.description="Alpine base image with nushell."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-alpine"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # Alpine versions
    ALPINE_MINOR=3.15 \
    ALPINE_REVISION=3.15.10 \
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
COPY ./3.15/overlay /

RUN chmod +x /preinstall && /preinstall
RUN bf-install

ENTRYPOINT [ "/init" ]
