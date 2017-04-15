## Vagrant Multiple-VM Creation and Configuration
Automatically provision multiple VMs (centos, ubuntu, windows) with Vagrant. Note that this support both VirtualBox and VMWare (Fusion, Workstation). 

Automatically install, configure, and test Puppet Master and Puppet Agents on those VMs.


#### JSON Configuration File
The Vagrantfile retrieves multiple VM configurations from a separate `nodes.json` file. All VM configuration is
contained in the JSON file. You can add additional VMs to the JSON file, following the existing pattern. The
Vagrantfile will loop through all nodes (VMs) in the `nodes.json` file and create the VMs. You can easily swap
configuration files for alternate environments since the Vagrantfile is designed to be generic and portable.

#### VMWare
```
{
  "nodes": {
    "puppet.example.com": {
      ":ip": "192.168.10.5",
      "ports": [
        {
          ":fwdhost": 8140,
          ":fwdguest": 8140,
          ":id": "port-1"
        }
      ],
      ":memory": 2048,
      ":bootstrap": "provision/bootstrap-master-centos.sh",
      ":boxname": "puppetlabs/centos-7.2-64-puppet",
      ":vendor": "vmware_fusion"
    },
    "node01.example.com": {
      ":ip": "192.168.10.10",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-centos.sh",
      ":boxname": "puppetlabs/centos-7.2-64-puppet",
      ":vendor": "vmware_fusion"
    },
    "node02.example.com": {
      ":ip": "192.168.10.11",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-centos.sh",
      ":boxname": "puppetlabs/centos-6.6-64-puppet",
      ":vendor": "vmware_fusion"
    },
    "node03.example.com": {
      ":ip": "192.168.10.20",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-ubuntu.sh",
      ":boxname": "puppetlabs/ubuntu-14.04-64-puppet",
      ":vendor": "vmware_fusion"
    },
    "node04.example.com": {
      ":ip": "192.168.10.21",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-ubuntu.sh",
      ":boxname": "puppetlabs/ubuntu-16.04-64-puppet",
      ":vendor": "vmware_fusion"
    },
    "windows.example.com": {
      ":ip": "192.168.10.50",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/windows.ps1",
      ":boxname": "addle/windows-server-2012-r2",
      ":vendor": "vmware_fusion"
    }
  }
}
```

#### VirtualBox
```

{
  "nodes": {
    "puppet.example.com": {
      ":ip": "192.168.10.5",
      "ports": [
        {
          ":fwdhost": 8140,
          ":fwdguest": 8140,
          ":id": "port-1"
        }
      ],
      ":memory": 2048,
      ":bootstrap": "provision/bootstrap-master-centos.sh",
      ":boxname": "puppetlabs/centos-7.2-64-puppet",
      ":vendor": "virtualbox"
    },
    "node01.example.com": {
      ":ip": "192.168.10.10",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-centos.sh",
      ":boxname": "puppetlabs/centos-7.2-64-puppet",
      ":vendor": "virtualbox"
    },
    "node02.example.com": {
      ":ip": "192.168.10.11",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-centos.sh",
      ":boxname": "puppetlabs/centos-6.6-64-puppet",
      ":vendor": "virtualbox"
    },
    "node03.example.com": {
      ":ip": "192.168.10.20",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-ubuntu.sh",
      ":boxname": "puppetlabs/ubuntu-14.04-64-puppet",
      ":vendor": "virtualbox"
    },
    "node04.example.com": {
      ":ip": "192.168.10.21",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/bootstrap-agent-ubuntu.sh",
      ":boxname": "puppetlabs/ubuntu-16.04-64-puppet",
      ":vendor": "virtualbox"
    },
    "windows.example.com": {
      ":ip": "192.168.10.50",
      "ports": [],
      ":memory": 1024,
      ":bootstrap": "provision/windows.ps1",
      ":boxname": "addle/windows-server-2012-r2",
      ":vendor": "virtualbox"
    }
  }
}
```

#### Instructions
```
vagrant up # brings up all VMs
vagrant ssh puppet

sudo systemctl status puppetmaster # test that puppet master was installed
sudo systemctl stop puppetmaster
sudo puppet master --verbose --no-daemonize
# Ctrl+C to kill puppet master
sudo systemctl start puppetmaster
sudo puppet cert list --all # check for 'puppet' cert

# Shift+Ctrl+T # new tab on host
vagrant ssh node01 # ssh into agent node
sudo systemctl status puppet # test that agent was installed
sudo puppet agent --test --waitforcert=60 # initiate certificate signing request (CSR)
```
Back on the Puppet Master server (puppet.example.com)
```
sudo puppet cert list # should see 'node01.example.com' cert waiting for signature
sudo puppet cert sign --all # sign the agent node(s) cert(s)
sudo puppet cert list --all # check for signed cert(s)
```
#### Forwarding Ports
Used by Vagrant and VirtualBox. To create additional forwarding ports, add them to the 'ports' array. For example:
 ```
 "ports": [
        {
          ":fwdhost": 1234,
          ":fwdguest": 2234,
          ":id": "port-1"
        },
        {
          ":fwdhost": 5678,
          ":fwdguest": 6789,
          ":id": "port-2"
        }
      ]
```
#### Useful Multi-VM Commands
The use of the specific <machine> name is optional.
* `vagrant up <machine>`
To startup  puppet server and linux nodes:
* `vagrant up puppet node0{1,2,3,4}`

* `vagrant reload <machine>`
* `vagrant destroy -f <machine> && vagrant up <machine>`
* `vagrant status <machine>`
* `vagrant ssh <machine>`
* `vagrant global-status`
* `facter`
* `sudo tail -50 /var/log/syslog`
* `sudo tail -50 /var/log/puppet/masterhttp.log`
* `tail -50 ~/VirtualBox\ VMs/postblog/<machine>/Logs/VBox.log'
