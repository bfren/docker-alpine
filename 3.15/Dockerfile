#======================================================================================================================
# STAGE 0: get build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.15.11" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.90.1" >> /log


#======================================================================================================================
# STAGE 1: load Nushell
#======================================================================================================================

FROM ghcr.io/bfren/nushell:0.90.1 as nushell


#======================================================================================================================
# STAGE 2: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-alpine3.15.11 AS busybox


#======================================================================================================================
# STAGE 3: install bfren platform
#======================================================================================================================

FROM alpine:3.15.11 as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=busybox / /bin
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

COPY ./overlay /
COPY ./3.15/overlay /

ENV \
    # path to bf configuration - installation script requires this
    BF_ETC=/etc/bf \
    # set container to this timezone
    BF_TZ=Europe/London \
    # whether or not to upgrade packages during installation
    #   0: no
    #   1: yes
    BF_UPGRADE_PACKAGES=0 \
    # Nushell version string to check against installed verion after installation
    NUSHELL_VERSION=0.90.1

RUN \
    # install busybox
    busybox --install && \
    # add packages required by Nushell
    apk add --no-cache libcrypto3 libgcc libssl3 sqlite-libs && \
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
