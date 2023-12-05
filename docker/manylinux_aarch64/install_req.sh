#!/bin/bash
set -e -x

# Pin versions
export VER_CMAKE=3.26.1
export VER_CENTOS_RELEASE_SCL=2-3.el7.centos
export VER_CONAN=1.59.0
export VER_DEVTOOLSET=9.1-0.el7
export VER_NINJA=1.11.1
export VER_PYBIND=2.10.3
export VER_PYTHON3_PIP=9.0.3-8.el7
export VER_PYTHON_DEVEL=3.8.13-1.el7
export VER_SCIKIT=0.16.7
export VER_SCL_UTILS=20130529-19.el7
export VER_SETUPTOOLS=59.6.0
export VER_WGET=1.14-18.el7_6.1
export VER_PERLIPCCMD=0.80-4.el7.noarch
export VER_PERLDIGESTSHA=5.85-4.el7.aarch64

# Install a system package required by our library
yum install -y centos-release-scl-$VER_CENTOS_RELEASE_SCL devtoolset-9-$VER_DEVTOOLSET rh-python38-python-devel-$VER_PYTHON_DEVEL python3-pip-$VER_PYTHON3_PIP scl-utils-$VER_SCL_UTILS wget-$VER_WGET
# These installs are required on aarch64 only for some reason
yum install -y perl-IPC-Cmd-$VER_PERLIPCCMD perl-Digest-SHA-$VER_PERLDIGESTSHA

source /opt/rh/devtoolset-9/enable
source /opt/rh/rh-python38/enable

pip3 install --upgrade pip
pip3 install cmake==$VER_CMAKE setuptools==$VER_SETUPTOOLS ninja==$VER_NINJA scikit-build==$VER_SCIKIT pybind11==$VER_PYBIND --force
pip3 install --user conan==$VER_CONAN --force

# Pre-load conan cache with build from local conan recipe instead of CCI to avoid having to wait for CCI review process
git clone https://github.com/opentdf/client-conan.git
cd client-conan
conan create recipe/all opentdf-client/$VCLIENT_CPP_VER@ -pr:b=default --build=opentdf-client --build=missing -o opentdf-client:branch_version=$VCONAN_BRANCH_VERSION
cd ..

./build-all.sh

./docker/manylinux_aarch64/build_wheels.sh
