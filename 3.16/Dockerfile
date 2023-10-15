FROM alpine:3.16.7 as build
COPY overlay/ 3.16/overlay/ /
RUN chmod +x /preinstall && /preinstall

FROM scratch
COPY --from=build / /

LABEL org.opencontainers.image.description="Alpine base image with nushell."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-alpine"

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # Alpine versions
    ALPINE_MINOR=3.16 \
    ALPINE_REVISION=3.16.7 \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=0 \
    # upgrade packages during installation
    BF_UPGRADE_PACKAGES=0 \
    # add bf executables to PATH
    PATH=/usr/bin/bf:${PATH}

RUN bf-install

ENTRYPOINT [ "/init" ]
