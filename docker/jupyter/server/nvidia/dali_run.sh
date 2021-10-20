#!/bin/bash

MOUNT_VOLUMES="/mnt/storage/data/pitn:/mnt/storage/data/pitn /srv/tmp/pitn:/srv/tmp/pitn /home/tas6hh/Projects:/home/jovyan/work" \
        ./run.sh tylerspears/jupyterlab:nvidia

