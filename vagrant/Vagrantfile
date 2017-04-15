# vi: set ft=ruby :

# Builds Puppet Master and multiple Puppet Agent Nodes using JSON config file

nodes = (JSON.parse(File.read("nodes.json")))['nodes']

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  nodes.each do |node|
    fqdn = node[0] # name of node
    hostname = fqdn.split('.')[0]
    node_values = node[1] # content of node

    config.vm.define hostname do |config|
      # configures all forwarding ports in JSON array
      ports = node_values['ports']
      ports.each do |port|
        config.vm.network :forwarded_port,
          host:  port[':fwdhost'],
          guest: port[':fwdguest'],
          auto_correct: true,
          id:    port[':id']
      end

      config.vm.box = node_values[':boxname']
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: node_values[':ip']

      config.vm.provider node_values[':vendor'] do |v|
        if node_values[':vendor'] == 'virtualbox'
          v.customize ["modifyvm", :id, "--memory", node_values[':memory']]
          v.customize ["modifyvm", :id, "--name", fqdn]
          v.cpus = 2
        else
          v.vmx["memsize"] = node_values[':memory']
          v.vmx["numvcpus"] = "2"
        end
      end

      if hostname == 'puppet'
        config.vm.synced_folder ".", "/vagrant"
        config.vm.synced_folder "../code", "/puppet_code", owner: "root", group: "root"
        config.vm.synced_folder "../puppetserver", "/puppet_puppetserver", owner: "root", group: "root"
      end

      #config.vm.provision "shell", privileged: false, inline: <<-EOF
      #  echo "Vagrant Box provisioned!"
      #  echo "Memory is: ******* #{node_values[':memory']} ********"
      #EOF

      config.vm.provision :shell, :path => node_values[':bootstrap']
    end
  end
end
