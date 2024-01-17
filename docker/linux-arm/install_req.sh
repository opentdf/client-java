#!/bin/bash
set -e -x

apt-get update &&  apt-get install -y --no-install-recommends build-essential=12.9ubuntu3 \
  cmake=3.22.1-1ubuntu1.22.04.1 \
  git=1:2.34.1-1ubuntu1.10 \
  openssh-client=1:8.9p1-3ubuntu0.6 \
  wget=1.21.2-2ubuntu1 \
  python3=3.10.6-1~22.04 \
  netbase=6.3 \
  openjdk-11-jdk=11.0.21+9-0ubuntu1~22.04 \
  maven=3.6.3-5 \
  swig=4.0.2-1ubuntu1 \
  curl=7.81.0-1ubuntu1.15 \
  jq=1.6-2.1ubuntu3 \
  python3-pip=22.0.2+dfsg-1ubuntu0.4 \
  && rm -rf /var/lib/apt/lists/*

python3 -m pip install --no-cache-dir conan==$VCONAN_VER

#Pre-load conan cache with build from local conan recipe instead of CCI to avoid having to wait for CCI review process
git clone https://github.com/opentdf/client-conan.git
cd client-conan
conan create recipe/all opentdf-client/$VCLIENT_CPP_VER@ -pr:b=default --build=opentdf-client --build=missing -o opentdf-client:branch_version=$VCONAN_BRANCH_VERSION
cd ..

./build-all.sh

