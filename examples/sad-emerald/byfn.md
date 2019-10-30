# Build Your First Network (BYFN)

# Overview of the Steps

# Each Of The Steps

## ./byfn.sh generate -c mychannel

1. ./byfn.sh generate -c mychannel
  1. generateCerts
  2. replacePrivateKey
  3. generateChannelArtifacts
  4. network
2. ./byfn up
3. ...connect to it...
4. ...wait for it...
5. ./byfn down

### generateCerts

This is a shell function which runs `cryptogen generate` on the `crypto-config.yaml` in the current directory.

```bash
cryptogen generate --config=./crypto-config.yaml
```

The file `crypto-config.yaml` is specified.

The output directory `crypto-config` is the default becaus ethe `--output` option is not given.

#### Results

There are 219 files & directories generated.

### replacePrivateKey

Whereas the filename of each private key is some sort of hash of the actual private key contained within the file blob, the script must edit the template file to contain the name of the private key.

| Input | `docker-compose-e2e-template.yaml` |
| Output | docker-compose-e2e.yaml` |

This is not really necessary as symbolic links could be used instead to allow the `docker-compose-e2e.yaml` specification to contain abstract names with the particulars of the key name beling hidden behind symbolic links names.

#### Procedure

```bash
#!/bin/sh
cd ${1?} && {
    directory=.
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
                ln -vfs ../keystore/*_sk ${file%.pem}.key
            done 
         fi
    ); done

}
```
#### Output

    'ca.org1.example.com-cert.key' -> 'fbfcb0f2537128db876d457559b29a756f601a4dc24b8936e4bfcd2e2e72ffb1_sk'
    'ca.org2.example.com-cert.key' -> '274df96eafc6051bdc4829f2cc0d6d3c075196b9d0d65ccdc4738d29e36fbc84_sk'
    'ca.example.com-cert.key' -> '4c3312e943dea49277d5f465485e59f83229bd956cc74dbc508df51d084a96d9_sk'
    'tlsca.org1.example.com-cert.key' -> '6d47ad62fedda9d00b80988d5a153406897df271f2f28f2437ae0fc7a0d5fb1b_sk'
    'tlsca.org2.example.com-cert.key' -> '9673cd87826e093b612e766b8ed32f4e2fbb2fb1d77d5161b8583139946154ab_sk'
    'tlsca.example.com-cert.key' -> '385e9d2ec796a73cac1680c9dba55f9d464fe5d034c51448f86543484663c2e4_sk'
    'Admin@org1.example.com-cert.key' -> '../keystore/11cea4aebccbba35260af05f4f1576cdbca505a9d3a1622ee2f865ac55506e52_sk'
    'Admin@org1.example.com-cert.key' -> '../keystore/f4b48dce5a5415c87dbc5b4a40cbaa1618160fcb6a3a060ef323b4f31209fb87_sk'
    'Admin@org1.example.com-cert.key' -> '../keystore/dc0e1110736fbbec69cc73598bc2ba1f961885bb0a52262cdb476a380940dd36_sk'
    'User1@org1.example.com-cert.key' -> '../keystore/e7a96611e55fa0376eb55b918c45d9108712d4bff72d38caf3664538811d82f3_sk'
    'Admin@org2.example.com-cert.key' -> '../keystore/357260aa041a87d742348e9c593c14f5221344b6917c18b37139ae0a8b21c07a_sk'
    'Admin@org2.example.com-cert.key' -> '../keystore/55d5b6cddf62edf23f23af34ba3257e6f05120c23e75d944557bfca4881f4e81_sk'
    'Admin@org2.example.com-cert.key' -> '../keystore/8a79205275d7c8aafa9e425a6726b1abf5250c2a9231bae9a8de397f7657baad_sk'
    'User1@org2.example.com-cert.key' -> '../keystore/297d1c8f2b90dd53a848f44f81eebab2d4b31971298e6dcc79053d901435ecdb_sk'
    'Admin@example.com-cert.key' -> '../keystore/9e49aba06dca4f99e508318e4d8254f6f32b64b35c7e447565ad03dde37aa635_sk'
    'Admin@example.com-cert.key' -> '../keystore/fd9e5cb4144c7102a5772e33a70fdbb45956642dd93be2e10607c30a754087bb_sk'

    'ca.org1.example.com-cert.key' -> 'fbfcb0f2537128db876d457559b29a756f601a4dc24b8936e4bfcd2e2e72ffb1_sk'
    'ca.org2.example.com-cert.key' -> '274df96eafc6051bdc4829f2cc0d6d3c075196b9d0d65ccdc4738d29e36fbc84_sk'
    'ca.example.com-cert.key' -> '4c3312e943dea49277d5f465485e59f83229bd956cc74dbc508df51d084a96d9_sk'
    'tlsca.org1.example.com-cert.key' -> '6d47ad62fedda9d00b80988d5a153406897df271f2f28f2437ae0fc7a0d5fb1b_sk'
    'tlsca.org2.example.com-cert.key' -> '9673cd87826e093b612e766b8ed32f4e2fbb2fb1d77d5161b8583139946154ab_sk'
    'tlsca.example.com-cert.key' -> '385e9d2ec796a73cac1680c9dba55f9d464fe5d034c51448f86543484663c2e4_sk'

#### Results

     find . -type l -print | xargs file
    ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/admincerts/Admin@org1.example.com-cert.key: symbolic link to ../keystore/11cea4aebccbba35260af05f4f1576cdbca505a9d3a1622ee2f865ac55506e52_sk
    ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/admincerts/Admin@org1.example.com-cert.key: symbolic link to ../keystore/f4b48dce5a5415c87dbc5b4a40cbaa1618160fcb6a3a060ef323b4f31209fb87_sk
    ./crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.key:                                             symbolic link to fbfcb0f2537128db876d457559b29a756f601a4dc24b8936e4bfcd2e2e72ffb1_sk
    ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/admincerts/Admin@org1.example.com-cert.key: symbolic link to ../keystore/dc0e1110736fbbec69cc73598bc2ba1f961885bb0a52262cdb476a380940dd36_sk
    ./crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/admincerts/User1@org1.example.com-cert.key: symbolic link to ../keystore/e7a96611e55fa0376eb55b918c45d9108712d4bff72d38caf3664538811d82f3_sk
    ./crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.key:                                       symbolic link to 6d47ad62fedda9d00b80988d5a153406897df271f2f28f2437ae0fc7a0d5fb1b_sk
    ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/admincerts/Admin@org2.example.com-cert.key: symbolic link to ../keystore/357260aa041a87d742348e9c593c14f5221344b6917c18b37139ae0a8b21c07a_sk
    ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/admincerts/Admin@org2.example.com-cert.key: symbolic link to ../keystore/55d5b6cddf62edf23f23af34ba3257e6f05120c23e75d944557bfca4881f4e81_sk
    ./crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.key:                                             symbolic link to 274df96eafc6051bdc4829f2cc0d6d3c075196b9d0d65ccdc4738d29e36fbc84_sk
    ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/admincerts/Admin@org2.example.com-cert.key: symbolic link to ../keystore/8a79205275d7c8aafa9e425a6726b1abf5250c2a9231bae9a8de397f7657baad_sk
    ./crypto-config/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/admincerts/User1@org2.example.com-cert.key: symbolic link to ../keystore/297d1c8f2b90dd53a848f44f81eebab2d4b31971298e6dcc79053d901435ecdb_sk
    ./crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.key:                                       symbolic link to 9673cd87826e093b612e766b8ed32f4e2fbb2fb1d77d5161b8583139946154ab_sk
    ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/admincerts/Admin@example.com-cert.key:        symbolic link to ../keystore/9e49aba06dca4f99e508318e4d8254f6f32b64b35c7e447565ad03dde37aa635_sk
    ./crypto-config/ordererOrganizations/example.com/ca/ca.example.com-cert.key:                                                    symbolic link to 4c3312e943dea49277d5f465485e59f83229bd956cc74dbc508df51d084a96d9_sk
    ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/admincerts/Admin@example.com-cert.key:             symbolic link to ../keystore/fd9e5cb4144c7102a5772e33a70fdbb45956642dd93be2e10607c30a754087bb_sk
    ./crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.key:                                              symbolic link to 385e9d2ec796a73cac1680c9dba55f9d464fe5d034c51448f86543484663c2e4_sk
    wbaker:wbaker@lemon-shaped [master !?+] [02/24/19T18:29:55] [F27 Twenty_Seven]
    [wbaker adm wheel users mock systemd-journal docker source oath backup bakers bakerfamily ketchum]
    /build/statespace/sad-emerald/sandbox


### generateChannelArtifacts

<!-- copied, with modifications, from byfns.sh -->

The `configtxgen` tool is used to create four artifacts:
1. orderer **bootstrap block**,
2. fabric **channel configuration transaction**,
3. two **anchor peer transactions** one for each peer organization
  * peer Org1
  * peer Org2

The orderer block is the `genesis block` for the ordering service, and the
channel transaction file is broadcast to the orderer at channel creation
time.  The anchor peer transactions, as the name might suggest, specify each
Org's anchor peer on this channel.

Configtxgen consumes a file - `configtx.yaml` - that contains the definitions
for the sample network. There are three members - one Orderer Org (``OrdererOrg``)
and two Peer Orgs (``Org1`` & ``Org2``) each managing and maintaining two peer nodes.

This file also specifies a consortium - ``SampleConsortium`` - consisting of our
two Peer Orgs.  Pay specific attention to the "Profiles" section at the top of
this file.  You will notice that we have two unique headers. One for the orderer genesis
block - ``TwoOrgsOrdererGenesis`` - and one for our channel - ``TwoOrgsChannel``.
These headers are important, as we will pass them in as arguments when we create
our artifacts.  This file also contains two additional specifications that are worth
noting.  Firstly, we specify the anchor peers for each Peer Org
(``peer0.org1.example.com`` & ``peer0.org2.example.com``).  

Secondly, we point to
the location of the MSP directory for each member, in turn allowing us to store the
root certificates for each Org in the orderer genesis block.  This is a critical
concept.<!-- meaning exactly what? ---> Now any network entity communicating with the ordering service can have
its digital signature verified.

This function will generate the crypto material and our four configuration
artifacts, and subsequently output these files into the ``channel-artifacts``
folder.

If you receive the following warning, it can be safely ignored:

    [bccsp] GetDefault -> WARN 001 Before using BCCSP, please call InitFactories(). Falling back to bootBCCSP.

You can ignore the logs regarding intermediate certs, we are not using them in
this crypto implementation.

Generate orderer genesis block, channel configuration transaction and
anchor peer update transactions

### Results

### Output


# Help

## cryptogen generate

```bash
$ cryptogen generate --help
usage: cryptogen generate [<flags>]

Generate key material

Flags:
  --help                    Show context-sensitive help (also try --help-long and --help-man).
  --output="crypto-config"  The output directory in which to place artifacts
  --config=CONFIG           The configuration template to use

```
