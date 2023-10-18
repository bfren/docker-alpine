#!/bin/sh

IMAGE=`cat VERSION`
ALPINE=${1:-3.18}

docker buildx build \
    --load \
    --no-cache \
    --progress plain \
    --build-arg BF_IMAGE=alpine \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${ALPINE}/Dockerfile \
    -t alpine${ALPINE}-dev \
    . \
    && \
    docker run -it -e BF_DEBUG=1 alpine${ALPINE}-dev nu
