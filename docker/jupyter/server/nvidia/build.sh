#!/bin/sh

set -e 

UID=`id --user`
JUPYTER_ENABLE_LAB=yes 
DOCKER_BUILDKIT=1

# Check for an https cert file.
# https://github.com/jupyter/notebook/issues/507#issuecomment-145390380
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#ssl-certificates
# https://jupyter-notebook.readthedocs.io/en/latest/public_server.html
if [ ! -f notebook.pem ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout notebook.pem -out notebook.pem
        sudo chown $UID notebook.pem
        sudo chmod 600 notebook.pem
fi
# Check for hashed password.
if [ ! -f hashed_passwd.txt ]; then
        ./hash_password.py
fi

# Build base-notebook with cudagl (CUDA & OpenGL) root image
BASE_DIR="../docker-stacks/base-notebook"
BASE_IMAGE="nvidia/cuda:11.1-cudnn8-runtime-ubuntu20.04@sha256:d0634b35474930e05adc569b87022d308c1e03c292680c62b4df8c35552f7708"

DOCKER_BUILDKIT=1 docker build \
        --build-arg ROOT_CONTAINER=${BASE_IMAGE} \
        --tag jupyterserver:_base \
        --file "$BASE_DIR/Dockerfile" \
        ${BASE_DIR}

# Build scipy-notebook with new base-notebook
MIN_DIR="../docker-stacks/minimal-notebook"
MIN_PARENT_CONTAINER="jupyterserver:_base"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=${MIN_PARENT_CONTAINER} \
        --tag jupyterserver:_minimal \
        --file "$MIN_DIR/Dockerfile" \
        ${MIN_DIR}

# Build scipy-notebook with new minimal-notebook
SCIPY_DIR="../docker-stacks/scipy-notebook"
SCIPY_PARENT_CONTAINER="jupyterserver:_minimal"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE_CONTAINER=${SCIPY_PARENT_CONTAINER} \
        --tag jupyterserver:_scipy \
        --file "$SCIPY_DIR/Dockerfile" \
        ${SCIPY_DIR}

# Build final image with image customizations.
PARENT_CONTAINER="jupyterserver:_scipy"
DOCKER_BUILDKIT=1 docker build \
        --build-arg BASE=$PARENT_CONTAINER \
        --tag jupyterserver:nvidia \
        --label device="nvidia" \
        --file nvidia.Dockerfile \
        .
