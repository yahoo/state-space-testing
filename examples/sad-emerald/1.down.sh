#!/bin/sh
cd ${0%/*} || exit 70
set -xve
: ${IMAGE_TAG:=latest}
: ${COMPOSE_PROJECT_NAME:=net}
# docker-compose reads these out of ./.env
export IMAGE_TAG COMPOSE_PROJECT_NAME

type -p docker docker-compose

: ${IMAGE_TAG:=latest}

IMAGE_TAG=${IMAGE_TAG?} docker-compose -f docker-compose-e2e.yaml down --volumes

# WATCHOUT - this destroys ALL containers on the host, not just the hyperledger fabric ones
docker ps -aq | xargs -r docker rm -f

# WATCHOUT this gets rid of many other things
#
# m/dev/       matches the chaincode images
# m/none/      matches what?
# m/test-vp/   sure kill it
# m/peer\d/    burn it with fire
#
docker images | awk '/(dev|none|test-vp|peer[0-9]-)/ {print $3}' | xargs -r docker rmi -f

#Delete any ledger backups
# <snide>
#  after all the unsafe things being done above, you're going to use docker to run rm in a container to remove ./ledgers-backup?
# </snide>
docker run -v $PWD:/tmp/first-network --rm hyperledger/fabric-tools:${IMAGE_TAG?} rm -Rf /tmp/first-network/ledgers-backup

rm -rf channel-artifacts crypto-config
