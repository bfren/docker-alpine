#!/bin/sh

IMAGE=`cat VERSION`
ALPINE=${1:-3.15}

git pull || exit 1
chmod +x run.sh

docker buildx build \
    --build-arg BF_IMAGE=alpine \
    --build-arg BF_VERSION=${IMAGE} \
    -f ${ALPINE}/Dockerfile \
    -t alpine${ALPINE}-dev \
    . \
    && \
    docker run -it alpine${ALPINE}-dev sh
