#!/bin/bash

ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/tim_chiang/.local/bin:/home/tim_chiang/bin:/root/a-fabric/bin:$PATH
export FABRIC_CFG_PATH=/root/a-fabric/config/
#export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

pushd ${ROOTDIR} > /dev/null
trap "popd > /dev/null" EXIT

#cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"



: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}

COMPOSE_FILE_BASE=compose-test-net.yaml


SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
DOCKER_SOCK="${SOCK##unix://}"
COMPOSE_FILES="-f compose/${COMPOSE_FILE_BASE} -f compose/${CONTAINER_CLI}/${CONTAINER_CLI}-${COMPOSE_FILE_BASE}"
DOCKER_SOCK="${DOCKER_SOCK}" ${CONTAINER_CLI_COMPOSE} ${COMPOSE_FILES} up -d 2>&1
$CONTAINER_CLI ps -a

echo "${DOCKER_SOCK}" ${CONTAINER_CLI_COMPOSE} ${COMPOSE_FILES} up -d 2>&1
