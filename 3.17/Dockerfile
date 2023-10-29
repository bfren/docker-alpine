#======================================================================================================================
# STAGE 0: get build information
#======================================================================================================================

FROM --platform=${BUILDPLATFORM} golang:alpine AS build
ARG TARGETPLATFORM

RUN \
    # save platform and version information to log
    echo "Platform: ${TARGETPLATFORM}" >> /log && \
    echo "Alpine: 3.17.5" >> /log && \
    echo "Nushell: 0.86.0" >> /log


#======================================================================================================================
# STAGE 1: load Nushell
#======================================================================================================================

FROM ghcr.io/bfren/nushell:0.86.0 as nushell


#======================================================================================================================
# STAGE 2: install bfren platform
#======================================================================================================================

FROM alpine:3.17.5 as install
COPY --from=build /log /etc/bf/BUILD
COPY --from=nushell / /

ARG BF_IMAGE
ARG BF_VERSION

ENV BF_ETC=/etc/bf \
    BF_UPGRADE_PACKAGES=0 \
    NUSHELL_VERSION=0.86.0

COPY ./overlay /
COPY ./3.17/overlay /

RUN chmod +x /preinstall && /preinstall
RUN /usr/bin/bf/bf-install


#======================================================================================================================
# STAGE 3: create final image
#======================================================================================================================

FROM scratch as final
COPY --from=install / /

LABEL org.opencontainers.image.description="Alpine base image with Nushell."
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
