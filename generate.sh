#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BUSYBOX_VERSION="1.37.0"
BUSYBOX_BUILD="261022"
FIGLET_VERSION="2.2.5"
FIGLET_BUILD="261022"
TJS_VERSION="26.6.0"
TJS_BUILD="260901"
ALPINE_EDITIONS="3.20 3.21 3.22 3.23 3.24"

for E in ${ALPINE_EDITIONS} ; do

    echo "Alpine ${E}"
    ALPINE_VERSION=`cat ./${E}/ALPINE_REVISION`
    BUSYBOX_IMAGE="${BUSYBOX_VERSION}-${BUSYBOX_BUILD}"
    FIGLET_IMAGE="${FIGLET_VERSION}-${FIGLET_BUILD}"
    NU_IMAGE="${TJS_VERSION}-alpine-${TJS_BUILD}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_EDITION=${E} \
        ALPINE_VERSION=${ALPINE_VERSION} \
        BUSYBOX_IMAGE=${BUSYBOX_IMAGE} \
        BUSYBOX_VERSION=${BUSYBOX_VERSION} \
        FIGLET_IMAGE=${FIGLET_IMAGE} \
        FIGLET_VERSION=${FIGLET_VERSION} \
        BF_BIN=/usr/bin/bf \
        BF_ETC=/etc/bf \
        NU_IMAGE=${NU_IMAGE} \
        TJS_VERSION=${TJS_VERSION}
    )

    echo "${DOCKERFILE}" > ./${E}/Dockerfile

    REPOS=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/repositories.esh" \
        ALPINE_MINOR=${E}
    )

    echo "${REPOS}" > ./${E}/overlay/etc/apk/repositories

done

#docker system prune -f
echo "Done."
