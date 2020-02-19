# Server Bootstraps

Those scripts you need to stand up a server quickly...

## Bootstrapping a Server

First thing you're going to need to do is ensure git is installed on your target server:

    yum -y install git

Then you should clone this repository, and run the relevant script for whichever type of server you're after:

    cd server-bootstraps
    ./centos/8.1/salt-master.sh


