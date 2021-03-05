#!/bin/sh

set -e

if [ ! -f ~/.cache/jupyterserver ]; then
        mkdir --parents ~/.cache/jupyterserver --mode 0755
        chown $UID:$GROUPS ~/.cache/jupyterserver
fi
if [ ! -f ~/.local/share/jupyterserver ]; then
        mkdir --parents ~/.local/share/jupyterserver --mode 0755
        chown $UID:$GROUPS ~/.local/share/jupyterserver
fi

HASHED_PASS=`cat hashed_passwd.txt`

docker run \
        --rm \
        --ipc=shareable \
        -p 10000:8888 \
        -e JUPYTER_ENABLE_LAB=yes \
        -e CONDA_ENVS_PATH="/opt/conda/envs:$CONDA_PREFIX/envs" \
        --volume $CONDA_PREFIX/envs:$CONDA_PREFIX/envs \
        --volume ~/Projects:/home/jovyan/work \
        --volume "$HOME/sync:$HOME/sync" \
        --volume "$PWD/notebook.pem:/etc/ssl/notebook.pem" \
        --volume ~/.cache/jupyterserver:/home/jovyan/.jupyter/lab \
        --volume ~/.local/share/jupyterserver:/home/jovyan/.local/share \
        jupyterserver:cpu start-notebook.sh \
        --ServerApp.certfile=/etc/ssl/notebook.pem \
        --ServerApp.base_url=/jupyter \
        --ServerApp.allow_password_change=False \
        --ServerApp.password=${HASHED_PASS}

