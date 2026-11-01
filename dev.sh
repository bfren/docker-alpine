#!/bin/sh

IMAGE=`cat VERSION`
ALPINE=${1:-3.24}

docker pull bfren/alpine:dev
docker run -it \
    -e BF_DEBUG=1 \
    -v $(pwd)/overlay/etc/tjs/scripts:/etc/tjs/scripts \
    bfren/alpine:dev sh
