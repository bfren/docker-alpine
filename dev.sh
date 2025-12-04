#!/bin/sh

IMAGE=`cat VERSION`
ALPINE=${1:-3.23}

docker pull bfren/alpine:dev
docker run -it \
    -e BF_DEBUG=1 \
    -v $(pwd)/overlay/etc/nu/scripts:/etc/nu/scripts \
    bfren/alpine:dev nu
