#!/bin/bash

#--- Configuring the second disk "data"
sudo parted --script --align optimal /dev/sdb mklabel gpt -- mkpart primary ext4 0% 100%
sudo mkfs --type ext4 /dev/sdb1
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
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
				
#-- Disabling firewalld
systemctl disable firewalld && systemctl stop firewalld

#--- Intalling PHP
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && yum-config-manager --enable remi-php73 && yum update -y
yum install -y php73 php73-php-{gd,fpm,ldap,xml,mbstring,pgsql,bcmath}
				
#--- Installing Python3
sudo yum install -y python3

#-- Installing PostgreSQL Server 12
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && yum update -y
yum install -y postgresql12-server postgresql12-contrib

#--- Starting PostgreSQL Server 12
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable postgresql-12
systemctl start postgresql-12

#--- Enabling MD5 on the file pg_hba.conf
sed -i -e 's/ident/md5/' /var/lib/pgsql/12/data/pg_hba.conf
systemctl reload postgresql-12
		
#--- Creating a User and DB on the PostgreSQL
sudo su postgres -c "psql -c \"CREATE USER zabbix5 WITH PASSWORD 'zbx#zbx'\" "
sudo su postgres -c "psql -c \"CREATE DATABASE zabbix5\" "
sudo su postgres -c "psql -c \"GRANT ALL ON DATABASE zabbix5 TO zabbix5\" "

#--- Altering password User postgres
sudo su postgres -c "psql -c \"ALTER USER postgres PASSWORD 'zabbix#zabbix'\" "

#--- Installing repo Zabbix 5 and essentials packages
rpm -ivh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum install -y zabbix-server-pgsql zabbix-agent fping net-snmp net-snmp-utils

#--- Populating database zabbix5
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | psql -h 127.0.0.1 -U zabbix5 -W 'zbx#zbx'

#--- Editing file zabbix_server.conf
sed -i -e 's/DBName=zabbix/DBName=zabbix5/' /etc/zabbix/zabbix_server.conf
sed -i -e 's/DBUser=zabbix/DBUser=zabbix5/' /etc/zabbix/zabbix_server.conf
sed -i -e 's/DBPassword=zabbix/DBPassword=zbx#zbx/' /etc/zabbix/zabbix_server.conf