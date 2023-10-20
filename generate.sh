#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_VERSIONS="3.15 3.16 3.17 3.18"
NUSHELL_VERSION="0.86.0"
for V in ${ALPINE_VERSIONS} ; do

    echo "Alpine ${V}"
    ALPINE_REVISION=`cat ./${V}/ALPINE_REVISION`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_VERSION=${V} \
        ALPINE_REVISION=${ALPINE_REVISION}\
        NUSHELL_VERSION=${NUSHELL_VERSION}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

    if [ "${V}" = "3.8" ] || [ "${V}" = "edge" ] ; then
        continue
    fi

    REPOS=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/repositories.esh" \
        ALPINE_MINOR=${V}
    )

    echo "${REPOS}" > ./${V}/overlay/etc/apk/repositories

done

docker system prune -f
echo "Done."
