#!/bin/bash

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppetserver" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Install Puppet Master
    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    sudo dpkg -i puppetlabs-release-trusty.deb && \
    sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    sudo apt-get install -yq puppetmaster

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.11   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null
    echo "192.168.10.20   node03.example.com  node03" | sudo tee --append /etc/hosts 2> /dev/null
    echo "192.168.10.21   node04.example.com  node04" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    #sudo `which puppet` module install puppetlabs-ntp
    #sudo `which puppet` module install garethr-docker
    #sudo `which puppet` module install puppetlabs-git
    #sudo `which puppet` module install puppetlabs-vcsrepo
    #sudo `which puppet` module install garystafford-fig

    # symlink manifest from Vagrant synced folder location
    #ln -s /vagrant/site.pp /etc/puppet/manifests/site.pp
fi
