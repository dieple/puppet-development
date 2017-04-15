#!/bin/bash

# Run on VM to bootstrap Puppet Master server

if [ -f "/etc/yum.repos.d/puppetlabs-pc1.repo" ]
then
  # remove old repo key
  sudo  mv /etc/yum.repos.d/puppetlabs-pc1.repo /etc/yum.repos.d/puppetlabs-pc1.repo.old
  sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
fi

if ps aux | grep "puppetserver" | grep -v grep 2> /dev/null
then
    echo "Puppet Server is already installed. Exiting..."
elif [ -f "/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver" ]
then
    echo "Puppet Server is already installed. Moving on..."
    sudo ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
    sudo ln -s /opt/puppetlabs/server/apps/puppetserver/bin/puppetserver /usr/bin/puppetserver
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
else
    # Install Puppet Server
    sudo yum update -y
    sudo yum install puppetserver -y
    sudo rm -rf /etc/puppetlabs/code
    sudo ln -s /puppet_code /etc/puppetlabs/code
    sudo rm -rf /etc/puppetlabs/puppetserver
    sudo ln -s /puppet_puppetserver /etc/puppetlabs/puppetserver
    # change jvm heapsize as VM has limited memory on vagrant!
    sudo sed -i 's/2g/512m/g' /etc/sysconfig/puppetserver

    # for "sudo puppet" commands to work!
    sudo ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
    sudo ln -s /opt/puppetlabs/server/apps/puppetserver/bin/puppetserver /usr/bin/puppetserver

    # Don't do this in production mode!
    #sudo touch /etc/puppetlabs/puppet/autosign.conf
    #echo "*.example.com" | sudo tee --append /etc/puppetlabs/puppet/autosign.conf 2> /dev/null

    sudo /opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
    sudo cp -r /vagrant/keys /etc/puppetlabs
    sudo chown puppet:puppet /etc/puppetlabs/keys/private_key.pkcs7.pem
    sudo chown puppet:puppet /etc/puppetlabs/keys/public_key.pkcs7.pem
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.11   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null
    echo "192.168.10.20   node03.example.com  node03" | sudo tee --append /etc/hosts 2> /dev/null
    echo "192.168.10.21   node04.example.com  node04" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppetlabs/puppet/puppet.conf
    sudo sed -i 's/.*\[master\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppetlabs/puppet/puppet.conf

    # Add the puppet https Port to the firewall
    sudo firewall-cmd --zone=public --add-port=8140/tcp --permanent
    sudo firewall-cmd --reload

    #sudo yum -y install rubygems-devel
    #gem install bundler
    #bundle install
    #gem install rake
    #gem install rspec
    #gem install puppet-lint
    #gem install rspec-puppet
    #gem install puppetlabs_spec_helper

    # Install some initial puppet modules on Puppet Master server
    #sudo puppet module install puppetlabs-ntp
    #sudo puppet module install garethr-docker
    #sudo puppet module install puppetlabs-git
    #sudo puppet module install puppetlabs-vcsrepo
    #sudo puppet module install garystafford-fig

    # symlink manifest from Vagrant synced folder location
    #ln -s /vagrant/site.pp /etc/puppet/manifests/site.pp
fi
