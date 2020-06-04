#!/bin/sh

# (c)2020 Brian Sidebotham <brian.sidebotham@gmail.com>
# License: MIT

# Script to create a salt master on a CentOS 8.1 minimal install server

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
basedir="${scriptdir}"
servername=$(basename ${0})
libdir="${basedir}/lib"
source "${libdir}"/lib.sh

echo "Building ${servername} for $(os_id) $(os_version_id)"

scriptfile_common="$(os_id)/${servername}"
scriptfile="$(os_id)/$(os_version_id)/${servername}"


if [ -f "${scriptfile_common}" ]; then
    must_succeed_or_exit /bin/bash ${scriptfile_common}
    if [ ! -f "${scriptfile}" ]; then
        exit 0
    fi
fi

if [ -f "${scriptfile}" ]; then
    must_succeed_or_exit /bin/bash ${scriptfile}
    if [ ! -f "${scriptfile}" ]; then
        exit 0
    fi
fi

echo "Don't have a script for this server/application combination" >&2
echo "common: ${scriptfile_common}" >&2
echo "script: ${scriptfile}" >&2
exit 1
