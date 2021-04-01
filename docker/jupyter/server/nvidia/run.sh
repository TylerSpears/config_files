#!/usr/bin/env bash

set -e

# Get directory of this bash script in case it is invoked from another directory.
SCRIPT_DIR=$(dirname $BASH_SOURCE)
UID=`id --user`
JUPYTER_ENABLE_LAB=yes 

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

if [ ! -f ~/.cache/jupyterserver ]; then
        mkdir --parents ~/.cache/jupyterserver --mode 0755
        chown $UID:$GROUPS ~/.cache/jupyterserver
fi
if [ ! -f ~/.local/share/jupyterserver ]; then
        mkdir --parents ~/.local/share/jupyterserver --mode 0755
        chown $UID:$GROUPS ~/.local/share/jupyterserver
fi
if [ ! -f ~/.config/jupyterserver ]; then
        mkdir --parents ~/.config/jupyterserver --mode 0755
        mkdir --parents ~/.config/jupyterserver/.jupyter --mode 0755
        chown -R $UID:$GROUPS ~/.config/jupyterserver
fi

HASHED_PASS=`cat "$SCRIPT_DIR/hashed_passwd.txt"`

docker run \
        --rm \
        --gpus=all \
        --ipc=shareable \
        -p 10000:8888 \
        -e JUPYTER_ENABLE_LAB=yes \
        -e CONDA_ENVS_PATH="/opt/conda/envs:$CONDA_PREFIX/envs" \
        --user $UID:$GROUPS \
        --volume $CONDA_PREFIX/envs:$CONDA_PREFIX/envs \
        --volume "$HOME/Projects:/home/jovyan/work" \
        --volume "$HOME/sync:$HOME/sync" \
        --volume "$SCRIPT_DIR/notebook.pem:/etc/ssl/notebook.pem" \
        --volume ~/.cache/jupyterserver:/home/jovyan/.cache \
        --volume ~/.local/share/jupyterserver:/home/jovyan/.local/share \
        --volume ~/.config/jupyterserver:/home/jovyan/.config \
        --volume ~/.config/jupyterserver/.jupyter:/home/jovyan/.jupyter \
        --volume /srv/tmp:/srv/tmp \
        --volume /srv/data:/srv/data \
        $1 start-notebook.sh \
        --ServerApp.certfile=/etc/ssl/notebook.pem \
        --ServerApp.base_url=/jupyter \
        --ServerApp.allow_password_change=False \
        --ServerApp.password=${HASHED_PASS}
