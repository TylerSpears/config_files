# FROM nvidia/cuda:11.2.0-cudnn8-runtime-ubuntu20.04

# FROM jupyter/scipy-notebook:latest
FROM nvidia/cuda@sha256:229e307193c402c85c42bb8ce10a9c0f38500d171462a593ececb5dcd94ba6a3
FROM jupyter/scipy-notebook@sha256:a1a58e23fe4fd2ccb1d55eb1c0d75d55933fe8eca8527b4bcba2ed2d9eb4d44c


COPY append_json.py append_json.py

RUN conda install --quiet --yes \
    nb_conda_kernels && \
    python -m nb_conda_kernels list && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
