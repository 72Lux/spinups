#!/usr/bin/env bash

(echo o; echo n; echo p; echo 1; echo ; echo; echo w) | sudo fdisk /dev/sdc
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir /data
sudo mount /dev/sdc1 /data
#remount on boot
sudo chmod 777 /etc/fstab
sudo echo "/dev/sdc1       /data   ext4    defaults,nofail        0       2" >> /etc/fstab
sudo chmod 644 /etc/fstab
