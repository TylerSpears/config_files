# Jupyter Server Docker Setup

Various setup scripts and Dockerfiles for running jupyter server on both a CPU
and a GPU (nvidia only).

## Requirements
- nvidia-container
- docker

## Secrets

Each `run.sh` script requires a certificate file (`notebook.sh`) and a *hashed* password
file (`hashed_passwd.txt`). The password hash can calculated with python; see 
<https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password>
for more details. Both files must be in the same location/directory as the `run.sh`
file.

