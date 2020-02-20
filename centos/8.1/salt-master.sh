#!/bin/sh

# (c)2020 Brian Sidebotham <brian.sidebotham@gmail.com>
# License: MIT

# Script to create a salt master on a CentOS 8.1 minimal install server

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
basedir="${scriptdir}"/../..
source "${basedir}"/lib/functions.sh

# The script must be run as the super user in order to do anything meaningful
must_be_root_or_exit

# Some people want to patch on building...
# must_succeed_or_exit \
#     yum -y update

# If using a proxy for internet access, yum will need to be configured to
# use it before we start using yum

# yum and dnf are both available on CentOS8 - the recommended approach from
# SaltStack is to use yum to install - we use the python3 repository. You're
# better off running your own local mirror in an enterprise so you can control
# the salt release process to suit your needs, but at home - pinned to the
# latest should suffice
must_succeed_or_exit \
    yum -y install https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el8.noarch.rpm

# Make sure we clean the yum cache so when we go to install something next,
# yum decides to go and fetch the package lists.
must_succeed_or_exit \
    yum clean expire-cache

# Install the packages required for a salt-master server. The salt-master
# should also be under it's own control, so we install the salt-minion on the
# salt-master too.
must_succeed_or_exit \
    yum -y install salt-master salt-minion salt-api

# Configure the salt-master for the first time - the settings we want to start
# with at least before the salt minion takes ownership of the salt master
# configuration.

# Configure the salt-minion for the first time. We need to make sure the salt
# minion is able to point back to the salt master in order to communicate.

