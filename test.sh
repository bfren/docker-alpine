#!/bin/sh

IMAGE=`cat VERSION`
ALPINE=${1:-3.19}

docker buildx build \
    --load \
    --build-arg BF_IMAGE=alpine \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${ALPINE}/Dockerfile \
    -t alpine${ALPINE}-test \
    . \
    && \
    docker run --rm alpine${ALPINE}-test env -i nu -c "use bf test ; test"
