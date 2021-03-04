#!/bin/sh

docker run \
    --rm \
    --gpus=all \
    --ipc=shareable \
    --env JUPYTER_ENABLE_LAB=yes \
    -p 10000:8888 \
    --volume "$PWD":/home/jovyan/Projects \
    --volume "$HOME/.local/share/jupyter/kernels":/home/jovyan/.local/share/jupyter/kernels \
    --volume /opt/miniconda/envs:/opt/conda/envs \
    --volume /srv/tmp:/srv/tmp \
    --volume /media/tyler/data:/srv/data \
    jupyterserver
