#!/bin/sh
set -e -x

sudo apt-get update;
if which puppet > /dev/null ; then
    echo "Puppet is already installed";
else
    echo "Installing puppet...";
    sudo apt-get install -y puppet;
    echo "Puppet installed!";
fi
echo "Installing puppet::python "
sudo puppet module install stankevich-python --version 1.18.2 --target-dir '/home/ubuntu/project/puppet/modules'
echo "Installing puppet::postgresql "
sudo puppet module install puppetlabs-postgresql --version 4.9.0 --target-dir '/home/ubuntu/project/puppet/modules'
