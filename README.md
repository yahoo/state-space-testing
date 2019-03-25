# State Space, Testing

This repository contains the end-to-end, reliability and performance test cases for the State Space implementation of the IAB PrivacyChain Reference Design.   These test cases relate to the State Space services and database manager.  

![banner](logo.png)

More detailed information can be found at the following locations
about the scope and purpose of the State Space implementation of the IAB PrivacyChain Reference Design.
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

## Install

This project is not independent. It expects to be configured as a submodule of [State Space](https://github.com/yahoo/statespace).  This should happen naturally in the course of the git submodule activation procedure.

To install the test code independently of its status as a submodule of State Space, run the following command:

```
git clone https://github.com/yahoo/statespace-testing.git
```

This will create a directory called `statespace-testing` and download the contents of this repo to it.

## Configuration

The following commands will configure the respository.  Individual test scenarios may have further configuration to operate them.

```
./buildconf &&
./configure
```

## Usage

Each individual test case will have a statement of purpose and how to run it.

## Security

This project doesn't have any security concerns.  It is a substantially self-contained set of test drivers and data.  However, for the larger test scenarios that span multiple machines, you should use your own and your organization's best practices when operating large multi-machine scenarios.

## Contribute

Please refer to [the contributing.md file](Contributing.md) for information about how to get involved. We welcome issues, questions, and pull requests. Pull Requests are welcome.

## Maintainers
Wendell Baker <wbaker@verizonmedia.com>

## License

This project is licensed under the terms of the [Apache 2.0](LICENSE-Apache-2.0) open source license. Please refer to [LICENSE](LICENSE) for the full terms.
