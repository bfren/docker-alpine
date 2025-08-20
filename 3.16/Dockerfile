#======================================================================================================================
# STAGE 0: store build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} ghcr.io/bfren/golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.16.9" >> /log && \
    echo "Busybox: 1.36.1" >> /log && \
    echo "Nushell: 0.106.1" >> /log


#======================================================================================================================
# STAGE 1: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-alpine3.16.9-250606 AS busybox


#======================================================================================================================
# STAGE 2: load Nushell
#======================================================================================================================

FROM ghcr.io/bfren/nushell:0.106.1-alpine-250606 AS nushell


#======================================================================================================================
# STAGE 3: install bfren platform
#======================================================================================================================

FROM alpine:3.16.9 AS install
COPY --from=build /log /etc/bf/BUILD
COPY --from=busybox / /bin
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

COPY ./overlay /
COPY ./3.16/overlay /

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
    NU_VERSION=0.106.1

RUN \
    # add packages required by Nushell
    apk add --no-cache libgcc sqlite-libs && \
    # install busybox
    busybox --install && \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 4: create final image
#======================================================================================================================

FROM scratch AS final
COPY --from=install / /

LABEL org.opencontainers.image.description="Alpine Linux with Nushell."
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
