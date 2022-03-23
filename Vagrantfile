# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = {
  'vagrant-zbx5' => { 'ip' => '192.168.200.10', 'memory' => '2048', 'cpus' => '2', 'disk' => 'D:\VirtualBox VMs\vagrant-zbx5\data.vdi' }
}

Vagrant.configure("2") do |config|
  #--- Customizing Vagrant Box in Vagrant Cloud
  servers.each do |name, conf|
    config.vm.define "#{name}" do |cfg|
      cfg.vm.box = "onobrerodrigo/centos-7-x86_64-minimal-2009"
      cfg.vm.box_version = "1.0.0"
      cfg.vm.box_check_update = true
      cfg.vm.hostname = "#{name}.#{conf['ip']}.nip.io"
      cfg.vm.network "private_network", ip: "#{conf['ip']}"
      cfg.vm.provision :hosts, :sync_hosts => true
	  
	  #--- Disable auto update vbguest
      cfg.vbguest.auto_update = false

      #--- Customizing Hardware on provider
	  cfg.vm.provider "virtualbox" do |vb|
        vb.name = "#{name}"
        vb.gui = false
        vb.cpus = "#{conf['cpus']}"
        vb.memory = "#{conf['memory']}"
        
		#--- Add second disk with 40GB. Define the variable named 'disk'. e.g. 'disk' => 'D:\VirtualBox VMs\vagrant-zbx5\data.vdi'
        vb.customize ['createhd', '--filename', "#{conf['disk']}", '--size', 20 * 1024]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "#{conf['disk']}"]
      end

      cfg.vm.provision "shell", path: "script.sh"
    end
  end
end