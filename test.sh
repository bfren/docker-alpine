#!/bin/bash

set -euo pipefail

ALPINE_EDITIONS="3.15 3.16 3.17 3.18 3.19"
for E in ${ALPINE_EDITIONS} ; do

    echo "Building Alpine ${E}."
    docker buildx build \
        --load \
        --quiet \
        --build-arg BF_IMAGE=alpine \
        --build-arg BF_VERSION=0.1.0 \
        -f ${E}/Dockerfile \
        -t alpine${E}-test \
        .

    echo "Running tests."
    docker run \
        -e BF_TESTING=1 \
        alpine${E}-test env -i nu -c "use nupm test ; test --dir /etc/nu/scripts/bf"

    echo ""

done
