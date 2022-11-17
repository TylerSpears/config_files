#!/bin/bash

set -eou pipefail

#JUPYTER_ENABLE_LAB=yes 
DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-1}"

# Build base-notebook with cuda and cudNN base image
BASE_DIR="${BASE_DIR:-../docker-stacks/base-notebook}"
#BASE_IMAGE="${BASE_IMAGE:-nvidia/cuda:11.1-cudnn8-runtime-ubuntu20.04@sha256:a5cd1ae5f3505d31167641c6591362e22ff853fc61c0870b0064c70ed022116b}"
#BASE_IMAGE="${BASE_IMAGE:-nvidia/cuda:11.4.2-cudnn8-runtime-ubuntu20.04}"
BASE_IMAGE="${BASE_IMAGE:-nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04}"

DOCKER_BUILDKIT=1 docker build \
        --build-arg ROOT_CONTAINER=${BASE_IMAGE} \
        --tag tylerspears/jupyterlab:_base \
        --file "$BASE_DIR/Dockerfile" \
        ${BASE_DIR}

# Build scipy-notebook with new base-notebook
MIN_DIR="../docker-stacks/minimal-notebook"
MIN_PARENT_CONTAINER="tylerspears/jupyterlab:_base"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=${MIN_PARENT_CONTAINER} \
        --tag tylerspears/jupyterlab:_minimal \
        --file "$MIN_DIR/Dockerfile" \
        ${MIN_DIR}

# Build scipy-notebook with new minimal-notebook
SCIPY_DIR="../docker-stacks/scipy-notebook"
SCIPY_PARENT_CONTAINER="tylerspears/jupyterlab:_minimal"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=${SCIPY_PARENT_CONTAINER} \
        --tag tylerspears/jupyterlab:_scipy \
        --file "$SCIPY_DIR/Dockerfile" \
        ${SCIPY_DIR}

# Build final image with image customizations.
PARENT_CONTAINER="tylerspears/jupyterlab:_scipy"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE=$PARENT_CONTAINER \
        --platform linux/amd64 \
        --tag tylerspears/jupyterlab:nvidia \
        --label device="nvidia" \
        --file nvidia.Dockerfile \
        .

# Remove intermediate build images.
docker image rm \
        tylerspears/jupyterlab:_scipy \
        tylerspears/jupyterlab:_minimal \
        tylerspears/jupyterlab:_base

