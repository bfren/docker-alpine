#!/bin/sh

git reset --hard && git pull
git checkout ${1:-main}
chmod +x pull.sh run.sh
