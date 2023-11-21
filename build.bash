#!/usr/bin/env bash

set -euxo pipefail

IMAGE="smi/aio"
CONTAINER_NAME="${IMAGE/\//_}_build"

docker build --pull --tag "${IMAGE}:build" .
docker container rm -f "${CONTAINER_NAME}" || true
docker run --rm -d --name "${CONTAINER_NAME}" "${IMAGE}:build"

ansible-playbook \
    --connection docker \
    --inventory "${CONTAINER_NAME}," \
    -e "ansible_python_interpreter=python3.10" \
    -e "host_role=Docker AIO" \
    site.yml

docker commit "${CONTAINER_NAME}" "${IMAGE}:latest"
docker kill "${CONTAINER_NAME}"
