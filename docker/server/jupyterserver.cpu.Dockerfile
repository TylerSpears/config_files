# https://hub.docker.com/layers/jupyter/scipy-notebook/latest/images/sha256-3518861a83647b977ee61059a2732f3808b20acceac2e3d44fcc8a6767707a6e?context=explore
FROM jupyter/scipy-notebook@sha256:3518861a83647b977ee61059a2732f3808b20acceac2e3d44fcc8a6767707a6e
USER root

RUN conda install --quiet --yes \
        'nb_conda_kernels=2.3.*' && \
        conda clean --all -f -y && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

USER $NB_UID

