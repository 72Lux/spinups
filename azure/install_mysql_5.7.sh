#!/bin/bash

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
#sudo sed -i 's#datadir\s*=.*#datadir=/data#' /etc/mysql/my.cnf
echo "resetting data dir"
echo "datadir=/data" >> /etc/mysql/my.cnf
sudo service mysql restart
#set the password
#sudo mysqladmin -u root password "$mysqlPassword"   #without -p means here the initial password is empty

#alternative update mysql root password method
#sudo mysql -u root -e "set password for 'root'@'localhost' = PASSWORD('$mysqlPassword')"
#without -p here means the initial password is empty

#sudo service mysql restart
