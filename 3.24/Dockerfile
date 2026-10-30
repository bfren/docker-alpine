# syntax=docker/dockerfile:1

#======================================================================================================================
# STAGE 0: store build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.24.3" >> /log && \
    echo "Busybox: 1.37.0" >> /log && \
    echo "txiki.js=26.6.0" >> /log


#======================================================================================================================
# STAGE 1: load busybox
#======================================================================================================================

FROM quay.io/bfren-bin/busybox:1.37.0-261022 AS busybox


#======================================================================================================================
# STAGE 2: load txikijs
#======================================================================================================================

FROM quay.io/bfren-bin/txikijs:26.6.0-alpine-260901 AS txikijs


#======================================================================================================================
# STAGE 3: load figlet
#======================================================================================================================

FROM quay.io/bfren-bin/figlet:2.2.5-261022 AS figlet


#======================================================================================================================
# STAGE 4: install bfren platform
#======================================================================================================================

FROM alpine:3.24.3 AS install
COPY --from=build /log /etc/bf/BUILD
COPY --from=busybox / /bin
COPY --from=txikijs / /bin
COPY --from=figlet / /

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

RUN \
    # install busybox
    busybox --install

ENV \
    # path to bf configuration - installation script requires this
    BF_ETC=/etc/bf \
    # set container to this timezone
    BF_TZ=Europe/London \
    # whether or not to upgrade packages during installation
    #   0: no
    #   1: yes
    BF_UPGRADE_PACKAGES=1 \
    # txiki.js version string to check against installed version after installation
    TJS_VERSION=26.6.0

COPY --exclude=etc/nu/scripts/tests ./overlay /
COPY ./3.24/overlay /

RUN \
    # setup txiki.js using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # ca-certificates is required but we don't want Debian to install it
    apk add --no-cache ca-certificates && \
    # run standard bf installation executable
    chmod +x /usr/bin/bf/bf-install && /usr/bin/bf/bf-install

COPY ./overlay/etc/nu/scripts/tests /etc/nu/scripts/tests


#======================================================================================================================
# STAGE 5: create final image
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
