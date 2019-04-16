#!/bin/sh

# (c)2019 Brian Sidebotham <brian.sidebotham@gmail.com>

# Script to bootstrap tvheadend server.
# OS: Ubuntu 18.04.2

if [ $# -ne 1 ]; then
    echo "Usage: ${0} password_for_nas_mount" >&2
    exit 1
fi

password=${1}

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run by root" >&2
    exit 1
fi

apt-get -y install coreutils wget apt-transport-https lsb-release ca-certificates
wget -qO- https://doozer.io/keys/tvheadend/tvheadend/pgp | apt-key add -
sh -c 'echo "deb https://apt.tvheadend.org/stable $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/tvheadend.list'
apt-get update

# Make sure we have the NAS mounted
apt-get -y install cifs-utils
mkdir -p /data > /dev/null 2>&1
echo '//nas.int.bjs/Public /data cifs username=Brian_S,password='${password}',uid=1000,gid=1000,vers=1.0,sec=ntlm,iocharset=utf8' >> /etc/fstab

mount -a

if [ $? -ne 0 ]; then
    echo "Failed to mount the NAS to /data" >&2
    exit 1
fi

# Install the application
echo "Installing tvheadend"
apt-get -y install tvheadend

systemctl enable tvheadend

# Configuration for TVHeadend lives on the NAS
