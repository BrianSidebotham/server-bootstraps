#!/bin/sh

# (c)2019 Brian Sidebotham <brian.sidebotham@gmail.com>

# Script to bootstrap tvheadend server.
# OS: CentOS 7

version_required="4.2-stable"

if [ $# -ne 1 ]; then
    echo "Usage: ${0} password_for_nas_mount" >&2
    exit 1
fi

password=${1}

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run by root" >&2
    exit 1
fi

which yum-config-manager > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Installing yum-config-manager"
    yum -y install yum-utils
fi

yum-config-manager --add-repo https://dl.bintray.com/tvheadend/centos/bintray-tvheadend-centos-${version_required}.repo

# Make sure we have the NAS mounted
yum -y install cifs-utils
mkdir -p /data > /dev/null 2>&1
echo '//nas.int.bjs/Public /data cifs username=Brian_S,password='${password}',uid=1000,gid=1000,vers=1.0,sec=ntlm,iocharset=utf8' >> /etc/fstab

mount -a

if [ $? -ne 0 ]; then
    echo "Failed to mount the NAS to /data" >&2
    exit 1
fi

# Install the application
echo "Installing tvheadend"
yum -y install tvheadend

systemctl enable tvheadend

# Configuration for TVHeadend lives on the NAS
