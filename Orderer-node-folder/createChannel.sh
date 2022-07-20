#!/bin/bash

ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export VERBOSE=false
pushd ${ROOTDIR} > /dev/null
trap "popd > /dev/null" EXIT
export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/tim_chiang/.local/bin:/home/tim_chiang/bin:/root/a-fabric/bin:$PATH
CHANNEL_NAME="mychannel-1"
DELAY="3"
MAX_RETRY="5"
VERBOSE="false"
: ${CHANNEL_NAME:="mychannel-1"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

: ${CONTAINER_CLI:="docker"}
: ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}


if [ ! -d "channel-artifacts" ]; then
        mkdir channel-artifacts
fi
echo "Generating channel genesis block '${CHANNEL_NAME}.block'"
echo "configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME"
configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"
echo "Creating channel ${CHANNEL_NAME}"
osnadmin channel join --channelID $CHANNEL_NAME --config-block ./channel-artifacts/${CHANNEL_NAME}.block -o orderer.cloudmile.com:7053 --ca-file /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/tlsca/tlsca.cloudmile.com-cert.pem --client-cert /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/orderers/orderer.cloudmile.com/tls/server.crt --client-key /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/orderers/orderer.cloudmile.com/tls/server.key
peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
