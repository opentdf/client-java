#!/bin/bash

set -x

# Linux aarch64 build
echo "Building aarch64 java sdk"
PLAT=aarch64
DOCKER_IMAGE=ubuntu:22.04

docker pull $DOCKER_IMAGE
docker run --rm \
   -v `pwd`:/io \
   -w /io \
   -e PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   -e PLAT=$PLAT \
   -e VCLIENT_CPP_VER \
   -e VCONAN_BRANCH_VERSION \
   -e VCONAN_RECIPE_VER \
   -e VCONAN_VER \
   -e VIRTRU_RUN_E2E_TESTS=false \
   $DOCKER_IMAGE \
   ./docker/linux-arm/install_req.sh
