#!/bin/bash

sudo yum update -y
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum install puppet-agent -y
sudo systemctl start puppet
