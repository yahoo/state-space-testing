#!/bin/bash
cd ${0%/*}/. || exit 70
# slam it down if it was already up
./1.down down 
# do the test
: up and down &&
    ./1.byfn.sh up &&
    ./1.down down &&
    echo OK
