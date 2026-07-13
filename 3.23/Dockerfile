# syntax=docker/dockerfile:1

#======================================================================================================================
# STAGE 0: store build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.23.5" >> /log && \
    echo "Busybox: 1.38.0" >> /log && \
    echo "txiki.js: 26.6.0" >> /log


#======================================================================================================================
# STAGE 1: load busybox
#======================================================================================================================

FROM quay.io/bfren/busybox:1.38.0-alpine3.23.5-260128 AS busybox


#======================================================================================================================
# STAGE 2: load txiki.js
#======================================================================================================================

FROM quay.io/bfren/txikijs:26.6.0-alpine3.24.1-260712 AS tjs


#======================================================================================================================
# STAGE 3: install bfren platform
#======================================================================================================================

FROM alpine:3.23.5 AS install
COPY --from=build /log /etc/bf/BUILD
COPY --from=busybox / /bin
COPY --from=tjs / /bin

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

RUN \
    # install busybox
    busybox --install && \
    # add coreutils env package to enable tjs shebangs
    apk add --no-cache coreutils-env

ENV \
    # path to bf configuration - installation script requires this
    BF_ETC=/etc/bf \
    # set container to this timezone
    BF_TZ=Europe/London \
    # whether or not to upgrade packages during installation
    #   0: no
    #   1: yes
    BF_UPGRADE_PACKAGES=0 \
    # txiki.js version string to check against installed version after installation
    TJS_VERSION=26.6.0

COPY --exclude=etc/tjs/scripts/tests ./overlay /
COPY ./3.23/overlay /

RUN \
    # setup txiki.js using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    chmod +x /usr/bin/bf/bf-install && /usr/bin/bf/bf-install

COPY ./overlay/etc/tjs/scripts/tests /etc/tjs/scripts/tests


#======================================================================================================================
# STAGE 4: create final image
#======================================================================================================================

FROM scratch AS final
COPY --from=install / /

LABEL org.opencontainers.image.description="Alpine Linux with txiki.js."
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
