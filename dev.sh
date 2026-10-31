#!/bin/sh

ALPINE=${1:-3.24}

docker pull bfren/alpine:alpine${ALPINE}-dev
docker run -it \
    -e BF_DEBUG=1 \
    -v $(pwd)/overlay/etc/nu/scripts:/etc/nu/scripts \
    bfren/alpine:alpine${ALPINE}-dev nu
