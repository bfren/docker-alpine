#======================================================================================================================
# STAGE 0: get build information and download envdir
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.17.8" >> /log && \
    echo "Nushell: 0.94.2" >> /log

WORKDIR /tmp
RUN \
    # build a URL to download and extract justc-envdir binary
    echo "Downloading justc-envdir." && \
    FILE="justc-envdir-1.0.1-linux" && \
    case "${TARGETPLATFORM}" in \
        linux/amd64) ARCH="amd64" ;; \
        linux/arm/v7) ARCH="armhf" ;; \
        linux/arm64) ARCH="aarch64" ;; \
        *) echo "Unsupported target platform: ${TARGETPLATFORM}." && exit 1 ;; \
    esac && \
    printf "%s" "${ARCH}" > ARCH && \
    wget https://github.com/just-containers/justc-envdir/releases/download/v1.0.1-1/${FILE}-${ARCH}.tar.gz && \
    tar -xvf ${FILE}-${ARCH}.tar.gz && \
    mv usr/bin/justc-envdir /usr/bin/envdir


#======================================================================================================================
# STAGE 1: load Nushell
#======================================================================================================================

FROM ghcr.io/bfren/nushell:0.94.2-alpine as nushell


#======================================================================================================================
# STAGE 2: install bfren platform
#======================================================================================================================

FROM alpine:3.17.8 as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=build /usr/bin/envdir /usr/bin/
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

COPY ./overlay /
COPY ./3.17/overlay /

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
    NUSHELL_VERSION=0.94.2

RUN \
    # add packages required by Nushell
    apk add --no-cache libcrypto3 libgcc libssl3 sqlite-libs && \
    # setup Nushell using preinstallation script
    chmod +x /preinstall && /preinstall && \
    # run standard bf installation executable
    /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 3: create final image
#======================================================================================================================

FROM scratch as final
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
