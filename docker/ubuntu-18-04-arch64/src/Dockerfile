FROM ubuntu:22.04
LABEL vendor="Virtru Corporation"

# build-essential for cmake/make
#ENV VCONAN_BRANCH_VERSION=VCONAN_BRANCH_VERSION

RUN echo $VCONAN_BRANCH_VERSION

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential \
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

RUN python3 -m pip install --no-cache-dir conan==1.59.0

# Pre-load conan cache with build from local conan recipe instead of CCI to avoid having to wait for CCI review process
RUN git clone https://github.com/opentdf/client-conan.git
RUN cd client-conan
RUN conan create recipe/all opentdf-client/1.5.6@ -pr:b=default --build=opentdf-client --build=missing -o opentdf-client:branch_version=$VCONAN_BRANCH_VERSION
RUN cd ..

WORKDIR /app

