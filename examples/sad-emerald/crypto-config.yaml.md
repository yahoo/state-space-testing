# crypto-config.yaml

The `crypto-config.yaml` file contains a specification of the Order and Peer Organizations.

The original `crypto-config.yaml` file comes with "documentation in place" as commentary.
This tutorial removes the commentary therein and elaborates upon the quirks and details.

The reader should consult the [Example](#Example) which is referenced throughout.

# Sections

## OrderOrgs
The `OrdererOrgs` section is the definition of the organizations which are managing _orderer_ nodes.

The expectation is that there will be relatively few of these.  The _orderer_ role does not have or need a lot of power
in either the operational or compute senses.
There can be multiple organizations which are perfomring the _orderer_ role.
The [Example](#Example) declares but one organization and one node (computer) performing that role.

The contents of this tag is a list of sub-objects.  In the YAML styling this means each sub-stanza begins with a dash.


### Name
The `Name` tag is a nmemonic identifier for a particular organization.
Keep this simple, something you'd be comfortable referencing later in the file.
So, if your company is named _Serene and Wonderful Experiences L.L.C._ then perhaps `SereneLLC` is a comfortable identifier.

### Domain
The `Domain` tag is an indication of the location of a computer which will be performing the _orderer_ role.
In practice it is a Qualified Domain Name (QDN).

### Specs
The `Specs` section contains a specification of all the hosts that will be performing the _Orderer_ role.

The `Specs` section is an array of _Spec entries_.  Each _Spec entry_ consists of two fields: `Hostname` and `CommonName`

#### `Hostname`

The simplist form of this specification is a list of `Hostname` which names each host an _unqualified_ or _fully qualified_ domain name.
When a Fully-Qualified Host Name (FQDN) is not used, the unqualified name is completed with the value of the `Domain` tag, which was described above.
Less helpfully, a specific host name can be named by its IP address in IPv4 or IPv6.

#### `CommonName`

Each `Hostname` may also have an affiliated `CommonName`, it is optional.
It is not clear why two sorts of naming are helpful for this capability.
The example from the original `crypto-config.yaml` is produced here _in toto_.

```
    - Hostname: foo
      CommonName: foo27.org5.example.com
```

This declares that the host `foo` which would normally be completed out to `foo.org1.example.com`, using the value of the `Domain` key above`
 # overrides Hostname-based FQDN set above
Why wouldn't you just say it simply as
```
    - Hostname: foo27.org5.example.com
```

### `Template`

An alternative to the `Specs` listing is the `Template`

There is a complicated syntax for computing the names and numbers of FQDNs.
This is described below in the `PeerOrgs` section where is most likely to be helpful.
The intent is, apparently, that the mini-language for computed names should avoid the operations crew having to build yet another layer of detemplatizing scripts upon top of these already-multi-layered bringup scripts.
 
## PeerOrgs

The `PeerOrgs` section is the definition of organizations managing peer nodes.  There will be many more peer organizations
and more nodes (computers) operating within these organizations.

As with the `OrderOrgs` tag, this contents of this stanza is a list of sub-objects.
In the YAML styling this means each sub-stanza begins with a dash.

### EnableNodeOUs

The value MUST be *true*.

This setting enable node (computer) _Organization Unit_ checking within the x.509 certificates that are generated.

The _Organizational Unit_ (*OU*) field in the client-supplicant certificates is used to establish what sort of authority the role shall have
in the system.  the scope and complexity of the roles and the access control language is beyond the scope of this tutorial.

### EnableNodeOUs: true

### Specs

An alternative to the `Specs` is the `Template`

### Template`

<!-- copied, with modifications, from crypto-config.yaml -->

Allows for the definition of one or more hosts that are created sequentially
from a template. By default, this looks like "peer%d" from 0 to Count-1.

#### Count

The count defaults to 0.
You may override the number of nodes with `Count`.

#### `Start`

The starting index defaults to 0.
You may override the starting index with `Start`.

#### `Hostname`

The hostname pattern defaults to "peer%d", where the `%d` is substituted with the index.

You may override this with `Hostname`

The `crypto-config.yaml` uses the following notation: <!-- and the go code says what?  Where is it? --->

```
    # Hostname: {{.Prefix}}{{.Index}}
```

The `Template` and `Specs` stanzas are not actually mutually exclusive.
You may define both sections and the aggregate nodes will be created for you.
Name collisions are an unchecked user error; you are responsible to avoid name collisions

### Users

An `Admin` user (certificate suite) is always generated. This certificate has power to operate the network.
* 
#### Count

The count of the user accounts _in addition_ to `Admin`.
Practically this number should be one (1).  You'll want at least one client with a non-administrative level.

It is not clear what role these users play in the BYFN system or in any system at all.
There are tutorials on the complicated nesting permissions systems that are possible with Hyperledger Fabric.
They are beyond the scope of this tutorial.


# Terminology

## Computer

When a community likes something, they develop many names for it.  "Baked Potato", "Can of Corn", "Round Trip", "Home Run."

* `host` is a computer.
* `instance` is a computer.
* `node` is a computer.

Also a _computer_ probably also an autonomous (uh) computer.  This being the era of _cloud native_, a _computer_ is probably
is a virtual machine operating on an actual computer ("bare metal",. "real iron") or a container pretending to be a computer.

* `container` is almost a computer.

## Docker

You aren't going to be able to run this stuff without it (yet).

* LXC - will work but not when controlled by libvirt.
* KVM - fine.

# Example


```yaml
OrdererOrgs:
  - Name: Orderer
    Domain: example.com
    Specs:
      - Hostname: orderer

PeerOrgs:
  - Name: Org1
    Domain: org1.example.com
    EnableNodeOUs: true
    Template:
      Count: 2
      # Start: 5
      # Hostname: {{.Prefix}}{{.Index}} # default
    Users:
      Count: 1
  # ---------------------------------------------------------------------------
  # Org2: See "Org1" for full specification
  # ---------------------------------------------------------------------------
  - Name: Org2
    Domain: org2.example.com
    EnableNodeOUs: true
    Template:
      Count: 2
    Users:
      Count: 1
```
