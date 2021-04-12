ARG BASE
FROM $BASE AS base
USER root

# Install extra utilities and system packages.
RUN apt-get update && apt-get install -yq --no-install-recommends \
        direnv \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

USER $NB_UID
# Install jupyterlab extensions and other notebook-related packages.
# Already installed from scipy-notebook base image:
# - ipywidgets (technically not an extension?)
# - ipympl
# - github.com/PAIR-code/facets
# 
# Install and set up the python language server 
# <https://github.com/krassowski/jupyterlab-lsp>.
# 
# Import black to generate initial grammar table. See
# <https://github.com/psf/black/issues/1143#issuecomment-730814683>.
RUN mamba install --quiet --yes \
        'bqplot=0.12.*' \
        'black=20.*' \
        'flake8=3.8.*' \
        'jupyterlab_code_formatter=1.4.*' \
        'jupyterlab-mathjax3=4.2.*' \
        'jupyterlab-katex=3.2.*' \
        'jupyter-lsp-python=1.1.*' \
        'jupyterlab-lsp=3.5.*' \
        'jupyterlab_execute_time=2.0.*' \
        'ipygany=0.5.*' \
        'vtk=9.0.*' \
        'pyvista=0.29.*' \
        'plotly=4.14.*' \
        'python-kaleido=0.2.*' \
        'nb_conda_kernels=2.3.*' && \
        pip install --pre --no-input --quiet --no-cache-dir \
        'jupyterlab_templates==0.3.*' \
        'jupyterlab-spellchecker==0.5.*' \
        'lckr-jupyterlab-variableinspector==3.0.*' \
        'aquirdturtle_collapsible_headings==3.0.*' \
        'git+https://github.com/krassowski/python-language-server.git@main' \
        'pyls-black==0.4.*' \
        'nbdime==3.0.*' && \
        python -c "import logging; logging.basicConfig(level='INFO'); import black" && \
        jupyter labextension install \
                @jupyterlab/apputils \
                @jupyterlab/celltags \
                @jupyterlab/toc-extension \
                @jupyterlab/debugger \
                jupyterlab-plotly@4.14 \
                plotlywidget@4.14 \
                ipygany && \
        jupyter-lab build -y && \
        jupyter-lab clean -y && \
        conda clean --all -f -y && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

        # 'k3d=2.9.*' \

######################################
# Setup for the ldconfig workaround.
# Only applicable if you are using nvidia-docker2 on Debian Testing or Experimental
# (which is roughly Debian 11, at the time of writing).
# If you have a different system, you should be able to comment out this block.
USER root
RUN adduser $NB_USER sudo \
        && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# SHELL ["/bin/bash", "-c"]
ENV ENTRYPOINT_WRAPPER="/home/$NB_USER/entrypoint.sh"
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
