#!/usr/bin/env bash

set -e

# Get directory of this bash script in case it is invoked from another directory.
SCRIPT_DIR=$(realpath $(dirname $BASH_SOURCE))
IMAGE_RUN_NAME="${1:-tylerspears/jupyterlab:nvidia}"
#JUPYTER_ENABLE_LAB=yes 

# env var of a space-separated list of mount paths. If a path contains a space ' ', make
# sure to enclose it in single quotes "'".
MOUNT_VOLUMES="${MOUNT_VOLUMES:- }"

# Check for an https cert file.
# https://github.com/jupyter/notebook/issues/507#issuecomment-145390380
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#ssl-certificates
# https://jupyter-notebook.readthedocs.io/en/latest/public_server.html
if [ ! -f "$SCRIPT_DIR"/notebook.pem ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$SCRIPT_DIR"/notebook.pem -out "$SCRIPT_DIR"/notebook.pem
        sudo chown $UID "$SCRIPT_DIR"/notebook.pem
        sudo chmod 600 "$SCRIPT_DIR"/notebook.pem
fi
# Check for hashed password.
if [ ! -f "$SCRIPT_DIR"/hashed_passwd.txt ]; then
        ."$SCRIPT_DIR"/hash_password.py
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

# Parse the space-separated list of MOUNT_VOLUMES and append onto VOLS_TO_MOUNT.
VOLS_TO_MOUNT=''
for mount in `echo $MOUNT_VOLUMES | grep -Po "(\'([\w\-./ ]+)+\:([\w\-./ ]+)+\')|(([\w\-./]+)+\:([\w\-./]+)+)" `; 
do
        VOLS_TO_MOUNT=$VOLS_TO_MOUNT"--volume $mount ";
done

docker run \
        --rm \
        --gpus=all \
        --ipc=host \
        --user=998:0 \
        --group-add=users \
        -p 10000:8888 \
        -e CONDA_ENVS_PATH="/opt/conda/envs:$CONDA_PREFIX/envs" \
        -e GEN_CERT=yes \
        --user $UID:$GROUPS \
        --volume $CONDA_PREFIX/envs:$CONDA_PREFIX/envs \
        --volume "$SCRIPT_DIR/notebook.pem:/etc/ssl/notebook.pem" \
        --volume ~/.cache/jupyterserver:/home/jovyan/.cache \
        --volume ~/.local/share/jupyterserver:/home/jovyan/.local/share \
        --volume ~/.config/jupyterserver:/home/jovyan/.config \
        --volume ~/.config/jupyterserver/.jupyter:/home/jovyan/.jupyter \
        $VOLS_TO_MOUNT \
        "$IMAGE_RUN_NAME" start-notebook.sh \
        --ServerApp.certfile=/etc/ssl/notebook.pem \
        --ServerApp.base_url=/jupyter \
        --ServerApp.allow_password_change=False \
        --ServerApp.password=${HASHED_PASS}

