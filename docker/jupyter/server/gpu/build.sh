#!/bin/sh

# NB_UID=$UID
# NB_GUID=$GUID
# NB_USER=guest

# # nvidia/cuda@sha256:229e307193c402c85c42bb8ce10a9c0f38500d171462a593ececb5dcd94ba6a3
# make \
#     -C docker-stacks \
#     -e DARGS='--build-arg ROOT_CONTAINER="nvidia/cuda:11.2.0-cudnn8-runtime-ubuntu20.04" --tag base-notebook'
#     build/base-notebook

# make \
#     -C docker-stacks \
#     -e DARGS='--build-arg BASE_CONTAINER=base-notebook --tag scipy-notebook' \
#     build/scipy-notebook

JUPYTER_ENABLE_LAB=yes 
DOCKER_BUILDKIT=1 
docker build \
    --tag jupyterserver:latest \
    -f jupyterlab.Dockerfile .