ARG BASE
FROM $BASE AS base
USER root

# Install extra utilities and system packages.
RUN apt-get update && apt-get install -yq --no-install-recommends \
        direnv \
        && apt-get clean && rm -rf /var/lib/apt/lists/*


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
# Install jupyterlab extensions and other notebook-related packages.
# Already installed from scipy-notebook base image:
# - ipywidgets (technically not an extension?)
# - ipympl
# - github.com/PAIR-code/facets
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
        'jupyterlab_execute_time=2.0.*' \
        'plotly=4.14.*' \
        'nb_conda_kernels=2.3.*' && \
        pip install --pre --no-input --quiet --no-cache-dir \
        'jupyterlab_templates==0.3.*' \
        'jupyterlab-spellchecker==0.5.*' \
        'lckr-jupyterlab-variableinspector==3.0.*' \
        'aquirdturtle_collapsible_headings==3.0.*' \
        'nbdime==3.0.*' && \
        python -c "import black; black.CACHE_DIR.mkdir(parents=True, exist_ok=True)" && \
        jupyter labextension install \
                @jupyterlab/apputils \
                @jupyterlab/celltags \
                @jupyterlab/toc-extension \
                @jupyterlab/debugger \
                jupyterlab-plotly@4.14 \
                plotlywidget@4.14 && \
        jupyter-lab build -y && \
        jupyter-lab clean -y && \
        conda clean --all --yes --force-pkgs-dirs && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

# Install jupyterlab language server.
RUN mamba install --quiet --yes \
        'jupyter-lsp-python=1.1.*' \
        'jupyterlab-lsp=3.5.*' && \
        pip install --pre --no-input --quiet --no-cache-dir \
        'git+https://github.com/krassowski/python-language-server.git@main' \
        'pyls-black==0.4.*' && \
        conda clean --all --yes --force-pkgs-dirs && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

# More prone-to-change installations, placed at the end to avoid unnecessary re-building
# above. These include the more niche visualization and other extensions.
RUN mamba install --quiet --yes \
        'vtk=9.0.*' \
        'pyvista=0.29.*' \
        'ipympl=0.7.*' \
        'python-kaleido=0.2.*' && \
        pip install --pre --no-input --quiet --no-cache-dir \
                'tensorflow-cpu==2.5.*' \
                'tensorboard==2.5.*' \
                'ipyvolume==0.6.0a8' && \
        jupyter-lab clean -y && \
        conda clean --all --yes --force-pkgs-dirs && \
        fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER
 
