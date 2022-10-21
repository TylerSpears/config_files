ARG BASE
FROM $BASE AS base
USER root

# Install extra utilities and system packages.
RUN apt-get update && apt-get install -yq --no-install-recommends \
        direnv jq \
        && apt-get clean && rm -rf /var/lib/apt/lists/*


######################################
# Setup for the ldconfig workaround.
# Only applicable if you are using nvidia-docker2 on Debian Testing or Experimental
# (which is roughly Debian 11, at the time of writing).
# If you have a different system, you should be able to comment out this block.
# USER root
# RUN adduser $NB_USER sudo \
#         && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# # SHELL ["/bin/bash", "-c"]
# ENV ENTRYPOINT_WRAPPER="/home/$NB_USER/entrypoint.sh"
# # Create an executable script that wraps the "CMD" executable(s).
# RUN touch "${ENTRYPOINT_WRAPPER}" \
#         && chmod +rx ${ENTRYPOINT_WRAPPER} \
#         && echo \
#         $'#!/bin/bash \n\
#         set -e\n\
#         sudo --non-interactive -u root ldconfig \n\
#         exec "$@"\n' \
#         >> ${ENTRYPOINT_WRAPPER}
# ENTRYPOINT ["./entrypoint.sh"]
# SHELL ["/bin/sh", "-c"]
######################################

USER $NB_UID
# Install jupyterlab extensions and other notebook-related packages.
# Already installed from scipy-notebook base image:
# - ipywidgets (technically not an extension?)
# - ipympl
# - github.com/PAIR-code/facets
# 
RUN conda config --system --prepend channels pytorch && \
        conda config --system --prepend channels nvidia && \
        mamba install --quiet --yes --no-channel-priority \
        'bqplot' \
        'black' \
        'flake8' \
        'jupyterlab_code_formatter' \
        'jupyterlab-mathjax3' \
        'jupyterlab-katex' \
        'jupyterlab_execute_time' \
        'plotly' \
        'jupyterlab-interactive-dashboard-editor' \
        'nb_conda_kernels' && \
        pip install --pre --no-input --quiet --no-cache-dir \
        'jupyterlab_templates' \
        'jupyterlab-spellchecker' \
        'lckr-jupyterlab-variableinspector' \
        'aquirdturtle_collapsible_headings' \
        'nbdime' && \
        python -c "import logging; logging.basicConfig(level='INFO'); import black" && \
        jupyter-lab build -y && \
        jupyter-lab clean -y && \
        mamba clean --all -f -y && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

# Install jupyterlab language server.
RUN mamba install --quiet --yes --no-channel-priority \
        'jupyter-lsp' \
        'jupyterlab-lsp' && \
        mamba install --quiet --yes --no-channel-priority \
        'python-lsp-server' && \
        mamba clean --all -f -y && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

# More prone-to-change installations, placed at the end to avoid unnecessary re-building
# above. These include the more niche visualization and other extensions.
RUN mamba install --quiet --yes --no-channel-priority \
        'vtk' \
        'pyvista' \
        'ipympl' \
        'ipyvtklink' \
        'python-kaleido' && \
        pip install --pre --no-input --quiet --no-cache-dir \
                'ipyvolume' && \
        mamba clean --all -f -y && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER
 
