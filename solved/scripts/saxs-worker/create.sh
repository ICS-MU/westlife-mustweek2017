#!/bin/bash

if [ `id -u` -ne 0 ]; then
        exec sudo -E /bin/bash -c "$0"
fi

set -x

PATH=/tmp/cloudify-ctx:$PATH

yum -y -d1 install wget openmpi environment-modules

imprpm=`ctx node properties imp_url`

ctx logger info "Downloading $imprpm"
wget $imprpm
yum -y -d1 localinstall `basename $imprpm`

ctx download-resource resources/saxs-worker/ensamble-fit '@{"target_path": "/usr/local/bin/ensamble-fit"}'
ctx download-resource resources/saxs-worker/foxs '@{"target_path": "/usr/local/bin/foxs"}'

adduser saxs
mkdir ~saxs/.ssh
ctx download-resource resources/ssh/id_rsa_saxs '@{"target_path": "/tmp/id_rsa_saxs"}'
mv /tmp/id_rsa_saxs ~saxs/.ssh/id_rsa

chown -R saxs ~saxs/.ssh
chmod 700 ~saxs/.ssh
chmod 400 ~saxs/.ssh/id_rsa
