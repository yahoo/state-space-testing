#!/bin/sh
cd ${0%/*} || exit 70

#
# Be polite and shut down the previous experiment before you start up this one.
#   ./down.sh
#
# Usage:
#
#  ./1.down.sh &&./1.byfn.sh && echo OK
#

set -exv
: ${IMAGE_TAG:=latest}
: ${COMPOSE_PROJECT_NAME:=net}
# docker-compose reads these out of ./.env
export IMAGE_TAG COMPOSE_PROJECT_NAME SYS_CHANNEL

# 1. ./byfn.sh generate -c mychannel
# 1.1. generateCerts
# 1.2. replacePrivateKey
# 1.3. generateChannelArtifacts
# 1.4. network
#
# 2. ./byfn.sh up -c mychannel
#    docker-compose
#
# 3. Channel Operations
# 3.1 createChannel
# 3.2 joinChannel foreach peer
# 3.3 updateAnchorPeers Org1
# 3.4 updateAnchorPeers Org2
#
# 4 Chaincode Installation
# 4.1 installChaincode     Org1 peer0.org1
# 4.2 installChaincode     Org2 peer0.org2
# 4.3 deferred until Step 5.3
#     installChaincode     Org2 peer1.org2
# 4.4 instantiateChaincode Org2 peer0.org2
#
# 5. Verification, The Chaincode Query
# 5.1 chaincodeQuery       Org1 peer0.org1
# 5.2 chaincodeInvoke      Org1 peer0.org1
# 5.2 instantiateChaincode Org2 peer1.org2
# 5.4 chaincodeQuery       Org2 peer1.org2
#

export PATH="/opt/hyperledger/fabric/bin:/exp/hyperledger/fabric/bin:$PATH"
type -p cryptogen configtxgen docker docker-compose

test -e crypto-config.yaml
test -e configtx.yaml
# NO NEED because these are *already* in the docker images that are run by docker-compose (below)
# NO NEED ---> test -e config/configtx.yaml
# NO NEED ---> test -e config/core.yaml
# NO NEED ---> test -e config/orderer.yaml
test -e peer-base.yaml
test -e docker-compose-base.yaml
test -e docker-compose-e2e.yaml
test -e ./.env # need for SYS_CHANNEL

# destroy the old
rm -rf crypto-config
rm -rf channel-artifacts

# 1.1 generateCerts
#
cryptogen generate --config=./crypto-config.yaml --output ./crypto-config

# 1.2. replacePrivateKey
#
# edits docker-compose-e2e.yaml
# we use the symbolic link technique described in in [byfn.md](byfn.md)<!--- right next door, but hosted where? --->
# ./1.byfn-symlink.sh
(
    directory=crypto-config
    for kind in ca tlsca; do
      for dir in $(find $directory -type d -name $kind); do (
          cd $dir && for file in $kind.*.pem ; do
            ln -vfs *_sk ${file%.pem}.key
          done 
      ); done
    done
    for dir in $(find $directory -type d -name admincerts); do (
        if [[ -d ${dir%/*}/keystore ]] ; then
            cd $dir && for file in *.pem ; do
                ( cd ../keystore && ln -vfs *_sk ${file%.pem}.key )
            done 
         fi
    ); done
)


# 1.3. generateChannelArtifacts
#
source ${0%/*}/.env && test -n "${SYS_CHANNEL?}"
declare CHANNEL=mychannel
mkdir -p channel-artifacts
test -e configtx.yaml
configtxgen -configPath . -profile TwoOrgsOrdererGenesis -channelID ${SYS_CHANNEL?} -outputBlock ./channel-artifacts/genesis.block
configtxgen -configPath . -profile TwoOrgsChannel        -channelID ${CHANNEL?} -outputCreateChannelTx ./channel-artifacts/${CHANNEL?}.tx
configtxgen -configPath . -profile TwoOrgsChannel        -channelID ${CHANNEL?} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -asOrg Org1MSP
configtxgen -configPath . -profile TwoOrgsChannel        -channelID ${CHANNEL?} -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -asOrg Org2MSP

# 1.4. network
#
# Yet more inplace sed substitution, which was already done in Step 1.2
# edits network-config-tls.yaml
# this is the developer's personal file (his name is apparently Jason, so sayeth the commentariat)
# it is not clear that this file is used in this demonstration.

# 2 ./byfn up
# 
#    IMAGE_TAG is referenced ni the yaml file
#    -f, --file FILE    Specify an alternate compose file (default: docker-compose.yml)
#    -d                 An undocumented "debug" mode?
#
IMAGE_TAG=latest docker-compose -f docker-compose-e2e.yaml up -d

#   timeout -------------------------------------------\  (here)
#   delay ------------------------------------\        |
#                                             |        |
#                                             |        | 
#                                             v        v
# docker exec cli scripts/script.sh mychannel 3 golang 10
# not using tls in this demo

docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
        peer channel create \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -o orderer.example.com:7050 \
            -c ${CHANNEL?} \
            -f ./channel-artifacts/${CHANNEL?}.tx \
            ${end}

#
# join
#
# needs config/core.yaml
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
	peer channel join \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -b ${CHANNEL?}.block \
            ${end}

docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer1.org1.example.com:7051 \
	peer channel join \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -b ${CHANNEL?}.block \
            ${end}

docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org2MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
	peer channel join \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -b ${CHANNEL?}.block \
            ${end}

docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org2MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
        CORE_PEER_ADDRESS=peer1.org2.example.com:7051 \
	peer channel join \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -b ${CHANNEL?}.block \
            ${end}

#
# update anchor peers
#
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
        peer channel update \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -o orderer.example.com:7050 \
            -c ${CHANNEL?} \
            -f ./channel-artifacts/Org1MSPanchors.tx \
            ${end}

docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org2MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
        peer channel update \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -o orderer.example.com:7050 \
            -c ${CHANNEL?} \
            -f ./channel-artifacts/Org2MSPanchors.tx \
            ${end}

#
# install chaincode
#
# recall: docker-compose-e2e.yaml maps  ./chaincode/:/opt/gopath/src/github.com/chaincode
# so the container sees /opt/gopath/src/github.com/chaincode/emerald_cc but it looks in the "standard GOPATH"
#
# WATCHOUT - there is no tls option for chaincode installation
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
        peer chaincode install \
            -n mycc -v 1.0 -l golang -p github.com/chaincode/emerald_cc \
            ${end}

docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org2MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
        peer chaincode install \
            -n mycc -v 1.0 -l golang -p github.com/chaincode/emerald_cc \
            ${end}

docker images
# instantiate requires hyperledger/fabric-ccenv:latest
if ! docker images | grep hyperledger/fabric-ccenv ; then
    docker pull hyperledger/fabric-ccenv:latest
fi
docker images | grep hyperledger/fabric-ccenv

#
# instantiate chaincode
#
# <quote ref=byfn.sh>
#   while the 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
#   lets supply it directly as we know it using the "-o" option.
# </quote>
#
#  -o, --orderer string                 Ordering service endpoint
#  -c, --ctor string                    Constructor message for the chaincode in JSON format (default "{}")
#  -P, --policy string                  The endorsement policy associated to this chaincode
#
# indeed, the instantiation happens first on peer0.org2
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org2MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
        peer chaincode instantiate \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -o orderer.example.com:7050 \
            -C ${CHANNEL?} \
            -n mycc \
            -l golang \
            -v 1.0 \
            -c '{"Args":["emeraldness","greenness"]}' \
            -P "OR ('Org1MSP.peer','Org2MSP.peer')" \
            ${end}

# If you do not wait, then the upcoming query will fail .  Why 3?  Who knows? Only The Shadow knows.
sleep 3
docker images

#
# query on peer0 of org1
#
# WATCHOUT - there is no tls for chaincode query
# --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
        peer chaincode query \
            -C ${CHANNEL?} \
            -n mycc \
            -c '{"Args":["get","emeraldness"]}' \
            ${end}

#
# invoke on peer0 of org1
#
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org1MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
        peer chaincode invoke \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -o orderer.example.com:7050 \
            -C ${CHANNEL?} \
            -n mycc \
            -c '{"Args":["set","emeraldness","sadness"]}' \
            ${end}
sleep 1

#
# query on peer0 of org2
#
# WATCHOUT - there is no tls for chaincode query
# --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
function __get_emeraldness_02() {
    docker exec cli \
        env \
            CORE_PEER_LOCALMSPID=Org2MSP \
            CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
            CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
            CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
            peer chaincode query \
                -C ${CHANNEL?} \
                -n mycc \
                -c '{"Args":["get","emeraldness"]}' \
                ${end}
}
__get_emeraldness_02
# see sadness
sleep 1
__get_emeraldness_02
# see sadness (again)

#
# invoke on peer0 of org2
#
docker exec cli \
    env \
        CORE_PEER_LOCALMSPID=Org2MSP \
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp \
        CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
        peer chaincode invoke \
            --tls true \
            --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
            -o orderer.example.com:7050 -C ${CHANNEL?} \
            -n mycc \
            -c '{"Args":["set","emeraldness","happiness"]}' \
            ${end}
sleep 1

# and check the other one to see that it propagated
function __get_emeraldness_01() {
    docker exec cli \
        env \
            CORE_PEER_LOCALMSPID=Org1MSP \
            CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
            CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp \
            CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
            peer chaincode query \
                -C ${CHANNEL?} \
                -n mycc \
                -c '{"Args":["get","emeraldness"]}' \
                ${end}
}
__get_emeraldness_01
# see 'happiness'
sleep 1
__get_emeraldness_01
# see 'happiness' (again)

echo "OK ${0##*/}"
