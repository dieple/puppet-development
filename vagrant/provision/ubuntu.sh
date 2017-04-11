#!/bin/bash

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get install puppet -y
sudo apt-get update
sudo puppet resource package puppet ensure=latest
sudo /usr/bin/bin/puppet agent --enable
sudo sed -i 's/START=no/START=yes/g' /etc/default/puppet
sudo service puppet start
