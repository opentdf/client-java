#!/bin/bash
set -e -x

apt-get update &&  apt-get install -y --no-install-recommends build-essential \
  valgrind \
  cmake \
  git \
  openssh-client \
  wget \
  python3 \
  netbase \
  openjdk-11-jdk \
  maven \
  swig \
  curl \
  jq \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

python3 -m pip install --no-cache-dir conan==$VCONAN_VER

#Pre-load conan cache with build from local conan recipe instead of CCI to avoid having to wait for CCI review process
git clone https://github.com/opentdf/client-conan.git
cd client-conan
conan create recipe/all opentdf-client/$VCLIENT_CPP_VER@ -pr:b=default --build=opentdf-client --build=missing -o opentdf-client:branch_version=$VCONAN_BRANCH_VERSION
cd ..

./build-all.sh

