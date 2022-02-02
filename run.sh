#!/bin/sh

VERSION=`cat VERSION`

git pull || true

docker buildx build \
    --build-arg BF_IMAGE=alpine \
    --build-arg BF_VERSION=${VERSION} \
    -f 3.15/Dockerfile \
    -t alpine-dev \
    .

docker run -it alpine-dev sh
