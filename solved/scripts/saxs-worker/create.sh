#!/bin/bash

if [ `id -u` -ne 0 ]; then
        exec sudo -E /bin/bash -c "$0"
fi

set -x

PATH=/tmp/cloudify-ctx:$PATH

yum -y -d1 install wget openmpi environment-modules
# wget https://integrativemodeling.org/2.6.2/download/IMP-2.6.2-1.el7.centos.x86_64.rpm
# yum -y -d1 localinstall IMP-2.6.2-1.el7.centos.x86_64.rpm

imprpm=`ctx node properties imp_url`

ctx logger info "Downloading $imprpm"
wget $imprpm
yum -y -d1 localinstall `basename $imprpm`

wget http://www.fi.muni.cz/~xracek/westlife/ensamble-fit -O /usr/local/bin/ensamble-fit
wget http://www.fi.muni.cz/~xracek/westlife/foxs -O /usr/local/bin/foxs
chmod +x /usr/local/bin/ensamble-fit
chmod +x /usr/local/bin/foxs
adduser saxs

mkdir ~saxs/.ssh
ctx download-resource resources/ssh/id_rsa_saxs '@{"target_path": "/tmp/id_rsa_saxs"}'
mv /tmp/id_rsa_saxs ~saxs/.ssh/id_rsa

chown -R saxs ~saxs/.ssh
chmod 700 ~saxs/.ssh
chmod 400 ~saxs/.ssh/id_rsa
