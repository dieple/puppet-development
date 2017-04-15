#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
    sudo ln -s `which puppet` /usr/bin/puppet
else
    sudo apt-get update -yq && sudo apt-get upgrade -yq
    sudo apt-get install -yq puppet
    sudo ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
fi

if cat /etc/crontab | grep puppet 2> /dev/null
then
    echo "Puppet Agent is already configured. Exiting..."
else
    sudo puppet resource cron puppet-agent ensure=present user=root minute=30 \
        command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

    sudo puppet resource service puppet ensure=running enable=true

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.10.11   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null
    echo "192.168.10.20   node03.example.com  node03" | sudo tee --append /etc/hosts 2> /dev/null
    echo "192.168.10.21   node04.example.com  node04" | sudo tee --append /etc/hosts 2> /dev/null

    # Add agent section to /etc/puppetlabs/puppet/puppet.conf
    echo "" && echo "[agent]\nserver=puppet" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null

    sudo puppet agent --enable
fi
