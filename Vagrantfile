# -*- mode: ruby -*-
# vi: set ft=ruby :

server = {
	'zabbix' => {'ip' => '192.168.200.10', 'memory' => '2048', 'cpus' => '1', 'disk' => 'D:\"virtualbox vms"\zabbix\data.vdi'}
}

Vagrant.configure("2") do |config|

	#--- Customizing Vagrant Box in Vagrant Cloud
	server.each do | name, conf|
		config.vm.define "#{name}" do |cfg|
			cfg.vm.box = "onobrerodrigo/centos-7-x86_64-minimal-2009"
			cfg.vm.box_version = "1.0.0"
			cfg.vm.box_check_update = true
			cfg.vm.box.hostname = "#{name}.#{conf['ip']}.nip.io"
			cfg.vm.network = "private_network", ip: "#{conf['ip']}"
			cfg.vm.provision :hosts, :sync_hosts => true

			#--- Disable auto update vbguest
			cfg.vbguest.auto_update = false

			#--- Customizing Hardware on provider
			cfg.vm.provider "virtualbox" do |vb|
				vb.name = "#{conf['name']}"
				vb.gui = false
				vb.cpus = "#{conf['cpus']}"
				vb.memory = "#{conf['memory']}"

				#--- Add second disk with 40GB. Define the variable named 'disk'. e.g. 'disk' => 'D:\"virtualbox vms"\zabbix\data.vdi'
				vb.customize ['createhd', '--filename', "#{conf['disk']}"], '--size', 40 * 1024]
				vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device' 0, '--type', 'hdd', 'medium', "#{conf['disk']}"]
		   	end

			cfg.vm.provision "shell", inline: <<-SHELL
				#--- Configuring the second disk "data"
				sudo parted --script --align optimal /dev/sdb mklabel gpt -- mkpart primary ext4 0% 100%
				sudo mkfs --type ext4 /dev/sbd1
				sudo mkdir /mnt/data
				sudo mount --types ext4 /dev/sdb1 /mnt/data
				sudo su -c "echo 'dev/sdb1 /mnt/data ext4 defaults 0 0 ' >> /etc/fstab"
				#--- Updating all packages to their latest version
    			sudo yum update && sudo yum upgrade -y

				#--- Installing default packages to the Server
				sudo yum install -y epel-releasecentos-release-scl yum-utils
				sudo yum groupinstall "Development Tools" -y
				sudo yum install -y vim wget net-tools
    			hostnamectl

				#--- Disabling selinux
				sudo setenforce 0
				sudo sed -i --follow-symlinks's/SELINUX=enforcing/SELINUX=disabled/g'/etc/sysconfig/selinux
				
				#-- Disabling firewalld
				systemctl disable firewalld && systemctl stop firewalld

				#--- Intalling PHP
				yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && yum-config-manager --enable remi-php73 && yum update -y
				yum install -y php73-php{gd,fpm,ldap,xml,mbstring,pgsql,bcmatch,php73}
				
				#--- Installing Python3
				sudo yum install -y python3

				#-- Installing PostgreSQL Server 12
				yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && yum update -y
				yum install -y postgresql12-server postgresql12-contrib

				#--- Starting PostgreSQL Server 12
				/usr/pgsql-12/bin/postgresql-12-setup initdb
				systemctl enable postgresql-12
				systemctl start postgresql-12
			SHELL
		end
	end
end


