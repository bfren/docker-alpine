#======================================================================================================================
# STAGE 0: get build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.17.5" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.86.0" >> /log


#======================================================================================================================
# STAGE 1: load Nushell
#======================================================================================================================

FROM ghcr.io/bfren/nushell:0.86.0 as nushell


#======================================================================================================================
# STAGE 2: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-alpine3.17 AS busybox


#======================================================================================================================
# STAGE 3: install bfren platform
#======================================================================================================================

FROM alpine:3.17.5 as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=busybox / /bin
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_VERSION

COPY ./overlay /
COPY ./3.17/overlay /

ENV \
    # path to bf configuration
    BF_ETC=/etc/bf \
    # whether or not to upgrade packages during installation
    #   0: no
    #   1: yes
    BF_UPGRADE_PACKAGES=0 \
    # Nushell version string to check against installed verion after installation
    NUSHELL_VERSION=0.86.0

RUN \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 4: create final image
#======================================================================================================================

FROM scratch as final
COPY --from=install / /

LABEL org.opencontainers.image.description="Alpine Linux with default Busybox and Nushell installed."
LABEL org.opencontainers.image.source="https://github.com/bfren/docker-alpine"

ENV \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=0 \
    # path to bfren configuration directory
    BF_ETC=/etc/bf \
    # add bfren executables to PATH
    PATH=/usr/bin/bf:${PATH}

ENTRYPOINT [ "/init" ]
