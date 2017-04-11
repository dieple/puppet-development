#!/bin/bash

sudo yum update -y
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum install puppetserver -y
sudo rm -rf /etc/puppetlabs/code
sudo ln -s /puppet_code /etc/puppetlabs/code
sudo rm -rf /etc/puppetlabs/puppetserver
sudo ln -s /puppet_puppetserver /etc/puppetlabs/puppetserver
# change jvm heapsize
sudo sed -i 's/2g/512m/g' /etc/sysconfig/puppetserver
# Don't do this in production mode!
sudo touch /etc/puppetlabs/puppet/autosign.conf
cat <<-EOF | sudo tee /etc/puppetlabs/puppet/autosign.conf >/dev/null
*.example.com
EOF
sudo /opt/puppetlabs/bin/puppetserver gem install hiera-eyaml
sudo cp -r /vagrant/keys /etc/puppetlabs
sudo chown puppet:puppet /etc/puppetlabs/keys/private_key.pkcs7.pem
sudo chown puppet:puppet /etc/puppetlabs/keys/public_key.pkcs7.pem
sudo systemctl start puppetserver
