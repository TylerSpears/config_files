ARG BASE_CONTAINER
ARG CUDNN_CONTAINER

FROM $BASE_CONTAINER AS base
# Copy CUDNN binaries from a matching container; CUDA should already be in the 
# BASE_CONTAINER.
# FROM $CUDNN_CONTAINER AS cudnn
USER root
# COPY --from=cudnn /usr/local/cuda/lib64/libcudnn* /usr/local/cuda/lib64

RUN conda install --quiet --yes \
        'nb_conda_kernels=2.3.*' && \
        conda clean --all -f -y && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

######################################
# Setup for the ldconfig workaround.
# Only applicable if you are using nvidia-docker2 on Debian Testing or Experimental
# (which is roughly Debian 11, at the time of writing).
# If you have a different system, you should be able to comment out this block.
RUN adduser ${NB_USER} sudo \
        && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# SHELL ["/bin/bash", "-c"]
ENV ENTRYPOINT_WRAPPER="/home/${NB_USER}/entrypoint.sh"
# Create an executable script that wraps the "CMD" executable(s).
RUN touch "${ENTRYPOINT_WRAPPER}" \
        && chmod +rx ${ENTRYPOINT_WRAPPER} \
        && echo \
        $'#!/bin/bash \n\
        set -e\n\
        sudo --non-interactive -u root ldconfig \n\
        exec "$@"\n' \
        >> ${ENTRYPOINT_WRAPPER}
ENTRYPOINT ["./entrypoint.sh"]
# SHELL ["/bin/sh", "-c"]
######################################

USER $NB_UID
