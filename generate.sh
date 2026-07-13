#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

BUSYBOX_VERSION="1.38.0"
BUSYBOX_BUILD="260128"
TJS_VERSION="26.6.0"
TJS_BUILD="260712"
ALPINE_EDITIONS="3.15 3.16 3.17 3.18 3.19 3.20 3.21 3.22 3.23 3.24"

for E in ${ALPINE_EDITIONS} ; do

    echo "Alpine ${E}"
    ALPINE_VERSION=`cat ./${E}/ALPINE_REVISION`
    BUSYBOX_IMAGE="${BUSYBOX_VERSION}-alpine${ALPINE_VERSION}-${BUSYBOX_BUILD}"
    TJS_IMAGE="${TJS_VERSION}-alpine3.24.1-${TJS_BUILD}"

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_EDITION=${E} \
        ALPINE_VERSION=${ALPINE_VERSION} \
        BUSYBOX_IMAGE=${BUSYBOX_IMAGE} \
        BUSYBOX_VERSION=${BUSYBOX_VERSION} \
        BF_BIN=/usr/bin/bf \
        BF_ETC=/etc/bf \
        TJS_IMAGE=${TJS_IMAGE} \
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
