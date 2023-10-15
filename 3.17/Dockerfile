FROM alpine:3.17.5 as build

COPY overlay/ 3.17/overlay/ /

RUN chmod +x /preinstall && /preinstall

FROM scratch

LABEL org.opencontainers.image.description="Alpine base image with nushell."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-alpine"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # Alpine versions
    ALPINE_MINOR=3.17 \
    ALPINE_REVISION=3.17.5 \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=0 \
    # upgrade packages during installation
    BF_UPGRADE_PACKAGES=0 \
    # set the location of the custom nu config files
    NU_CONFIG_DIR=/etc/bf/nu \
    # add bf executables to PATH
    PATH=/usr/bin/bf:${PATH}

COPY --from=build / /

RUN bf-install

ENTRYPOINT [ "/init" ]
