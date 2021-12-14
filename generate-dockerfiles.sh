#!/bin/bash

set -euo pipefail

ALPINE_VERSIONS="3.12 3.13 3.14 3.15 edge"
for V in ${ALPINE_VERSIONS} ; do

    echo "Alpine: ${V}"
    ALPINE_REVISION=`cat ./${V}/ALPINE_REVISION`

    DOCKERFILE=$(docker run \
        -v ${PWD}:/ws \
        bfren/alpine esh \
        "/ws/Dockerfile.esh" \
        ALPINE_VERSION=${V} \
        ALPINE_REVISION=${ALPINE_REVISION}
    )

    echo "${DOCKERFILE}" > ./${V}/Dockerfile

done

echo "Done."