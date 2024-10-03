#======================================================================================================================
# STAGE 0: store build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.19.4" >> /log && \
    echo "Nushell: 0.98.0" >> /log

WORKDIR /tmp
RUN \
    # build a URL to download Nushell
    echo "Building Nushell download URL." && \
    case "${TARGETPLATFORM}" in \
        "linux/amd64") ARCH="x86_64" ;; \
        "linux/arm/v7") ARCH="armv7" ;; \
        "linux/arm64") ARCH="aarch64" ;; \
        *) echo "Unsupported target platform: ${TARGETPLATFORM}." && exit 1 ;; \
    esac && \
    RELEASES=https://github.com/nushell/nushell/releases/download/0.98.0 && \
    FILE=nu-0.98.0-${ARCH}-unknown-linux-musl && \
    EXT=tar.gz && \
    URL=${RELEASES}/${FILE}.${EXT} && \
    # build a URL to download Nushell
    echo "Downloading Nushell from ${URL}." && \
    wget ${URL} && \
    # extract Nushell and move it to root
    echo "Extracting Nushell." && \
    tar -xf ${FILE}.${EXT} && \
    mv ${FILE}/ /nu


#======================================================================================================================
# STAGE 1: bring Nushell files together
#======================================================================================================================

FROM scratch AS nushell
COPY --from=build /nu/nu /usr/bin/
COPY --from=build /nu/nu_plugin* /root/.config/nushell/plugins/
ADD https://raw.githubusercontent.com/bfren/nushell/main/0.98.0/config.nu /root/.config/nushell/config.nu
ADD https://raw.githubusercontent.com/bfren/nushell/main/0.98.0/env.nu /root/.config/nushell/env.nu



#======================================================================================================================
# STAGE 2: load busybox
#======================================================================================================================

FROM ghcr.io/bfren/busybox:1.36.1-alpine3.19.4-240913 AS busybox


#======================================================================================================================
# STAGE 3: install bfren platform
#======================================================================================================================

FROM alpine:3.19.4 AS install
COPY --from=build /log /etc/bf/BUILD
COPY --from=busybox / /bin
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

COPY ./overlay /
COPY ./3.19/overlay /

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
    NU_VERSION=0.98.0

RUN \
    # add packages required by Nushell
    apk add --no-cache libcrypto3 libgcc libssl3 sqlite-libs && \
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
