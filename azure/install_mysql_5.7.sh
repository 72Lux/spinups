#!/bin/bash

echo "Mounting data drive .............."
(echo o; echo n; echo p; echo 1; echo ; echo; echo w) | sudo fdisk /dev/sdc
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir /data
sudo mount /dev/sdc1 /data
#remount on boot
sudo chmod 777 /etc/fstab
sudo echo "/dev/sdc1       /data   ext4    defaults,nofail        0       2" >> /etc/fstab
sudo chmod 644 /etc/fstab
echo "Data dir now exists and will be remounted on boot"



mysqlPassword=$1
sudo apt-get -y update
sudo apt-get -y upgrade
#no password prompt while installing mysql server
#export DEBIAN_FRONTEND=noninteractive

#another way of installing mysql server in a Non-Interactive mode
echo "setting password"
echo "mysql-server-5.6 mysql-server/root_password password $mysqlPassword" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $mysqlPassword" | sudo debconf-set-selections

#install mysql-server 5.7
echo "installing mysql-server 5.7"
sudo apt-get -y install mysql-server-5.7
echo "mysql successully installed"

echo "changing mount ownership for new mysql data dir"
sudo mkdir -p /data/lib/mysql
sudo cp -r /var/lib/mysql/* /data/lib/mysql
sudo chown mysql:mysql /data/lib/mysql
sudo chmod 700 /data/lib/mysql
echo "resetting data dir"
sudo service mysql stop
sudo rm -r /var/lib/mysql
ln -s /data/lib/mysql /var/lib/mysql
sudo chmod -R 777 /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo sed -i 's:/var/lib/mysql:/data/lib/mysql:g' /etc/apparmor.d/usr.sbin.mysqld
sudo service apparmor restart
echo "restarting mysql ........."
sudo service mysql start
#sudo sed -i 's#datadir\s*=.*#datadir =   /data/lib/mysql#' /etc/mysql/mysql.conf.d/mysqld.cnf
#set the password
#sudo mysqladmin -u root password "$mysqlPassword"   #without -p means here the initial password is empty

#alternative update mysql root password method
#sudo mysql -u root -e "set password for 'root'@'localhost' = PASSWORD('$mysqlPassword')"
#without -p here means the initial password is empty

#sudo service mysql restart
