#!/bin/bash

set -x
# Install necessary binaries
yum -y install wget openmpi environment-modules

# TODO get & install IMP library
# TODO install ensamble-fit & foxs from resources to /usr/local/bin