# State Space, Testing

This repository contains the end-to-end, reliability and performance test cases for the State Space implementation of the IAB PrivacyChain Reference Design.   These test cases relate to the State Space services and database manager.

![banner](logo.png)

More detailed information
about the scope and purpose of the State Space implementation of the IAB PrivacyChain Reference Design
can be found at the following locations:
* [State Space](https://github.com/yahoo/statespace)
* [IAB PrivacyChain](https://github.com/InteractiveAdvertisingBureau/PrivacyChain/blob/master/README.md) Reference Design.

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contribute](#contribute)
- [License](#license)

## Background

This project contains several sorts of tests for the PrivacyChain database manager.  These are:
* long-running end-to-end transactional tests
* high-load stress tests
* operability and recoverabilty tests

Not all of these test scenarios are implemented in the 0.1 release.

## Dependencies

The [configuration](#configuration) step will check for many but not all required packages and operating system features.  There is a list of known [package-dependencies](https://github.com/yahoo/state-space-testing/blob/master/PACKAGES.md) which you will need to install beyond your base operating system.

Generally, the dependencies are among:
- The Hyperledger Fabric database and its Public Key Infrastructure (PKI) services.
- Various components of the Tunitas system; <em>e.g.</em> the [Basic Components](https://github.com/yahoo/tunitas-basic).
- A modern (C++2a) development environment.
- A recent Fedora, but any recent Linux distro should suffice.

The State Space project was developed on Fedora 27 through Fedora 30 using GCC 7 and GCC 8 with `-fconcepts` and at least `-std=c++1z`.  More details on the development environment and the build system can be found in [temerarious-flagship](https://github.com/yahoo/temerarious-flagship/blob/master/README.md).

## Install

This project is not independent. It expects to be configured as a submodule of [State Space](https://github.com/yahoo/statespace).  This should happen naturally in the course of the git submodule activation procedure.

To install the test code independently of its status as a submodule of State Space, run the following command:

```
git clone https://github.com/yahoo/statespace-testing.git
```

This will create a directory called `statespace-testing` and download the contents of this repo to it.

## Configuration

You can configure and build the test drivers with the following recipe:

``` bash
./buildconf &&
./configure &&
make check &&
make install &&
echo OK DONE
```

## Usage

Each individual test case will have a statement of purpose and instructions describing how to run it.

## Contents

Again, a reminder: these are stress tests which populate the database on their own terms.  They should be used wisely and on on test databases (test channels) only. They should not be applied to the network.

* [full-of-gravel](https://github.com/yahoo/statespace-testing/blob/master/tests/full-of-gravel) fills the database with random data.
* [reps-and-sets](https://github.com/yahoo/statespace-testing/blob/master/tests/reps-and-sets) exercises CRUD in the database with its own data set.

## Security

This project doesn't have any direct security concerns.  It is a substantially self-contained set of test drivers and data.  However, for the larger test scenarios that span multiple machines, you should use your own and your organization's best practices when operating large multi-machine scenarios.

## Contribute

Please refer to [the contributing.md file](Contributing.md) for information about how to get involved. We welcome issues, questions, and pull requests. Pull Requests are welcome.

## Maintainers
Wendell Baker <wbaker@verizonmedia.com>

## License

This project is licensed under the terms of the [Apache 2.0](LICENSE-Apache-2.0) open source license. Please refer to [LICENSE](LICENSE) for the full terms.
