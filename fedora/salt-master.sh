#!/bin/sh

# (c)2020 Brian Sidebotham <brian.sidebotham@gmail.com>
# License: MIT

# Script to create a salt master on a CentOS 8.1 minimal install server

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
basedir="${scriptdir}"/..
libdir="${basedir}/lib"
source "${libdir}"/functions.sh

# The script must be run as the super user in order to do anything meaningful
must_be_root_or_exit

# Install the packages required for ea salt-master server. The salt-master
# should also be under it's own control, so we install the salt-minion on the
# salt-master too.
must_succeed_or_exit \
    yum -y install salt-master salt-minion salt-api salt-cloud salt-ssh

# Configure the salt-master for the first time - the settings we want to start
# with at least before the salt minion takes ownership of the salt master
# configuration.

# Configure the salt-minion for the first time. We need to make sure the salt
# minion is able to point back to the salt master in order to communicate.

