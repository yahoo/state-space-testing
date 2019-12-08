#!/bin/sh
cd ${0%/*} || exit 70

set -exv
: ${IMAGE_TAG:=latest}
: ${COMPOSE_PROJECT_NAME:=net}
# docker-compose reads these out of ./.env
export IMAGE_TAG COMPOSE_PROJECT_NAME SYS_CHANNEL

export PATH="/opt/hyperledger/fabric/bin:/exp/hyperledger/fabric/bin:$PATH"
type -p cryptogen configtxgen docker docker-compose

test -e configtx.yaml
test -e ./.env # need for SYS_CHANNEL

# destroy NOTHING

# DO NOT regenerate the certificates

source ${0%/*}/.env && test -n "${SYS_CHANNEL?}"
declare CHANNEL=mychannel
mkdir -p channel-artifacts
test -e configtx.yaml
configtxgen -configPath . -profile TwoOrgsOrdererGenesis -channelID ${SYS_CHANNEL?} -outputBlock ./channel-artifacts/genesis.block
configtxgen -configPath . -profile TwoOrgsChannel        -channelID ${CHANNEL?} -outputCreateChannelTx ./channel-artifacts/${CHANNEL?}.tx
configtxgen -configPath . -profile TwoOrgsChannel        -channelID ${CHANNEL?} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -asOrg Org1MSP
configtxgen -configPath . -profile TwoOrgsChannel        -channelID ${CHANNEL?} -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -asOrg Org2MSP

echo "OK ${0##*/}"
