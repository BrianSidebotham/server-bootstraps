#!/bin/sh

# (c)2019 Brian Sidebotham <brian.sidebotham@gmail.com>
# Author: Brian Sidebotham

# Builds a development FoundationDB server

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ "$(id -u)X" != "0X" ]; then
    echo "This script must be run by root (uid=0)" >&2
    exit 1
fi

foundation_webpage=https://apple.github.io/foundationdb/downloads.html
staging_dir=/root

# Find the HTML line that has the link in we need to get the foundationdb version information
html=$(curl ${foundation_webpage} | grep 'https://.*rhel7.*foundationdb-clients[-a-zA-Z\.0-9_]\+\.rpm"')

major=$(echo $html | sed 's/.*foundationdb-clients-\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\).*/\1/g')
minor=$(echo $html | sed 's/.*foundationdb-clients-\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\).*/\2/g')
patch=$(echo $html | sed 's/.*foundationdb-clients-\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\).*/\3/g')
release=$(echo $html | sed 's/.*foundationdb-clients-\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)-\([0-9]\+\).*/\4/g')

echo "Configuring server with FoundationDB ${major}.${minor}.${patch}"

client_rpm_filename=foundationdb-clients-${major}.${minor}.${patch}-${release}.el7.x86_64.rpm
server_rpm_filename=foundationdb-server-${major}.${minor}.${patch}-${release}.el7.x86_64.rpm

client_rpm_url=https://www.foundationdb.org/downloads/${major}.${minor}.${patch}/rhel7/installers/${client_rpm_filename}
server_rpm_url=https://www.foundationdb.org/downloads/${major}.${minor}.${patch}/rhel7/installers/${server_rpm_filename}

# Download the RPM packages and then install.
wget -O ${staging_dir}/${client_rpm_filename} ${client_rpm_url}
wget -O ${staging_dir}/${server_rpm_filename} ${server_rpm_url}

rpm -Uvh ${staging_dir}/${client_rpm_filename} ${staging_dir}/${server_rpm_filename}
