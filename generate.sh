#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_EDITIONS="3.15 3.16 3.17 3.18"
NUSHELL_VERSION="0.86.0"
for E in ${ALPINE_EDITIONS} ; do

    echo "Alpine ${E}"
    ALPINE_VERSION=`cat ./${E}/ALPINE_REVISION`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_EDITION=${E} \
        ALPINE_VERSION=${ALPINE_VERSION}\
        NUSHELL_VERSION=${NUSHELL_VERSION}
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

docker system prune -f
echo "Done."
