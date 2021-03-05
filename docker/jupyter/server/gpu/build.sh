#!/bin/sh

set -e 

JUPYTER_ENABLE_LAB=yes 
DOCKER_BUILDKIT=1

# https://github.com/jupyter/notebook/issues/507#issuecomment-145390380
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#ssl-certificates
# https://jupyter-notebook.readthedocs.io/en/latest/public_server.html
if [ ! -f notebook.pem ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout notebook.pem -out notebook.pem
        sudo chown $UID notebook.pem
        sudo chmod 600 notebook.pem
fi

# make \
#     -C docker-stacks \
#     -e DARGS='--build-arg ROOT_CONTAINER="nvidia/cuda:11.2.0-cudnn8-runtime-ubuntu20.04" --tag base-notebook'
#     build/base-notebook

# Build base-notebook with cudagl (CUDA & OpenGL) root image
BASE_DIR="../docker-stacks/base-notebook"
BUILD_ROOT_CONTAINER="nvidia/cudagl:11.2.0-runtime-ubuntu20.04@sha256:51590d1361ed8abb41d35bb8b6cd05fc55e55a25fde99d60624dc3cc8a5a1def"
# root image is from the tag `nvidia/cudagl:11.2.0-runtime-ubuntu20.04`
DOCKER_BUILDKIT=1 docker build \
        --build-arg ROOT_CONTAINER=${BUILD_ROOT_CONTAINER} \
        --tag jupyterserver:base \
        --file "$BASE_DIR/Dockerfile" \
        ${BASE_DIR}

# Build scipy-notebook with new base-notebook
MIN_DIR="../docker-stacks/minimal-notebook"
MIN_PARENT_CONTAINER="jupyterserver:base"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=${MIN_PARENT_CONTAINER} \
        --tag jupyterserver:minimal \
        --file "$MIN_DIR/Dockerfile" \
        ${MIN_DIR}

# Build scipy-notebook with new minimal-notebook
SCIPY_DIR="../docker-stacks/scipy-notebook"
SCIPY_PARENT_CONTAINER="jupyterserver:minimal"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=${SCIPY_PARENT_CONTAINER} \
        --tag jupyterserver:scipy \
        --file "$SCIPY_DIR/Dockerfile" \
        ${SCIPY_DIR}

# Build final image with image customizations.
GPU_BASE_CONTAINER="jupyterserver:scipy"
CUDNN_CONTAINER="nvidia/cuda:11.2.0-cudnn8-runtime-ubuntu20.04@sha256:d67327ce5f9667da4e5b82970483ebbc56d92fea32449a3e74fcde60cd8488ae"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=$GPU_BASE_CONTAINER \
        --build-arg CUDNN_CONTAINER=$CUDNN_CONTAINER \
        --tag jupyterserver:gpu \
        --file jupyterserver.gpu.Dockerfile \
        .
