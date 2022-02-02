#!/bin/bash

set -euo pipefail

docker pull bfren/alpine

ALPINE_VERSIONS="3.8 3.12 3.13 3.14 3.15 edge"
for V in ${ALPINE_VERSIONS} ; do

    echo "Alpine ${V}"
    ALPINE_REVISION=`cat ./${V}/ALPINE_REVISION`

    SILENT=$(docker run \
        -v ${PWD}:/in \
        -v ${PWD}/${V}:/out \
        -e ALPINE_VERSION=${V} \
        -e ALPINE_REVISION=${ALPINE_REVISION} \
        bfren/alpine bf-esh \
        /in/Dockerfile.esh \
        /out/Dockerfile
    )

done

docker system prune -f
echo "Done."
