#!/bin/sh

set -e 

# https://github.com/jupyter/notebook/issues/507#issuecomment-145390380
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#ssl-certificates
# https://jupyter-notebook.readthedocs.io/en/latest/public_server.html
if [ ! -f notebook.pem ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout notebook.pem -out notebook.pem
        sudo chown $UID notebook.pem
        sudo chmod 600 notebook.pem
fi


DOCKER_BUILDKIT=1 docker build -t jupyterserver:cpu --file jupyterserver.cpu.Dockerfile .
