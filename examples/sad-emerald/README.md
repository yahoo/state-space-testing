# Scope Span & Purpose

This is stripped-down and didactic version of PrivacyChain's BYFN (Build Your Own First Network).
It is intended as a didactic aid in comprehending the processes, tooling & technology in PrivacyChain
and its use of Hyperledger Fabric.

The working tutorial is derived from materials found upstream at:
* Microsoft's GitHub [PrivacyChain.git](https://github.com/InteractiveAdvertisingBureau/PrivacyChain.git).
* And presumably also hosted locally at your organization's git hubbery.

# Usage

To bring up the network and run some simple tests:
```bash
./1.byfn.sh && echo OK

```
To redo, you must take down the running network with `./1.down.sh` before bringing up the network again:

```bash
./1.down.sh &&./1.byfn.sh && echo OK
```

# Materials

The tutorial considers, from PrivacyChain.git the script kids, in rough order of usage in FN (First Network) bringup.

* `docker/downloadFabricCommandPullFabricImages.sh`
* `dockerocker/bin/get-docker-images.sh`
* `dockerocker/byfn.sh`
* `dockerocker/eyfn.sh`

And during operations upon the running network

* `docker/db_init.sh`
* `docker/scripts/step3org3.sh`
* `docker/scripts/utils.sh`
* `docker/scripts/step1org3.sh`
* `docker/scripts/upgrade_to_v11.sh`
* `docker/scripts/testorg3.sh`
* `docker/scripts/step2org3.sh`
* `docker/scripts/script.sh`

# Procedure

The tutorial covers a much simplified usage of the original `byfn.sh`
That usage, in the genreal case is:

```bash
byfn.sh generate -c mychannel
byfn.sh up -c mychannel -s couchdb
byfn.sh up -c mychannel -s couchdb -i 1.1.0
byfn.sh up -l node
byfn.sh down -c mychannel
byfn.sh upgrade -c mychannel
```

And when taking all defaults:

``` bash
byfn.sh generate
byfn.sh up
byfn.sh down
```

The `askProceed` barrier has been removed always and everywhere.

The [usage)(#Usage) section above covers this simplified usage only.

# License

Licensing is under the same terms as PrivacyChain.git.  The license statement is nearby.
It is copied verbatim from [LICENSE](https://github.com/InteractiveAdvertisingBureau/PrivacyChain/blob/master/LICENSE).
It is the [Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0) license.
