#!/bin/bash

# enable debugging and also exit immediately if a command exits with error.
set -ex

# some constants
TAG_VERSION=1.9.1
CURRENT_DIR=$(pwd)
DOCKER_IMAGE=virtru-tdf3-cpp/ubuntu-22.04-arch64:${TAG_VERSION}

# NOTE: when upgrading to different version tag make sure update this script
# to remove the previous version image

# some debug logs
echo "Running the linux build for ${DOCKER_IMAGE}..."
echo "Current dir - ${CURRENT_DIR}..."

# check if docker image exists if not build one
if [[ "$(docker images -q ${DOCKER_IMAGE} 2> /dev/null)" == "" ]]; then
	echo "Info: building docker image  ${DOCKER_IMAGE}..."
	docker build -t ${DOCKER_IMAGE} docker/ubuntu-18-04-arch64/src/.
else
	echo "Info: Reusing existing docker image ${DOCKER_IMAGE}..."
fi

BUILDKITE_DOCKER=${BUILDKITE:-false}

if [[ $BUILDKITE_DOCKER == "true" ]]; then
  source buildkite-scripts/mars/functions/aws.sh
  export VAULT_TOKEN=$(get_ssm_parameter_secret_by_name "/secret/common/buildkite_build_agent/buildkite_qa_vault_token" "us-west-2")
fi

VCONAN_BRANCH_VERSION="123123"

# run the image
docker run --rm -ti \
	-v ${CURRENT_DIR}:/app \
	-v ~/.ssh:/root/.ssh \
	-w /app \
	-e PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin \
	-e VCLIENT_CPP_VER \
    -e ${VCONAN_BRANCH_VERSION} \
    -e VCONAN_RECIPE_VER \
    -e VEXPORT_COMBINED_LIB \
	 ${DOCKER_IMAGE} \
	 /bin/bash

