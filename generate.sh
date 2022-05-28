#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_VERSIONS="3.8 3.9 3.10 3.11 3.12 3.13 3.14 3.15 3.16 edge"
for V in ${ALPINE_VERSIONS} ; do

    echo "Alpine ${V}"
    ALPINE_REVISION=`cat ./${V}/ALPINE_REVISION`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        -e BF_DEBUG=0 \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_VERSION=${V} \
        ALPINE_REVISION=${ALPINE_REVISION}
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
