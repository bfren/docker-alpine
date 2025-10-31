#!/bin/sh

IMAGE=`cat VERSION`
ALPINE=${1:-3.22}

docker run -it \
    -e BF_DEBUG=1 \
    -v $(pwd)/overlay/etc/nu/scripts:/etc/nu/scripts \
    ghcr.io/bfren/alpine nu
