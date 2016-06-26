#!/usr/bin/env bash

#setup azure cli
# sudo apt-get -y install npm
# npm install azure-cli -g
# sudo ln -s /usr/bin/nodejs /usr/bin/node
# azure account import azureShoppable.publishsettings
# azure config mode arm
# azure login -u ubuntu@shoppableoutlook.onmicrosoft.com -p Bazaar889



# #azure group create myResourceGroup westus
# azure group deployment create /
# --template-file azuredeploy.json /
# --parameters-file azuredeploy.parameters.json sc-1 solr-replica
#
# azure group deployment create -f azuredeploy.json -e azuredeploy.parameters.json sc-1 solr-replica
#  azure group deployment create -f azuredeployAS.json -e azuredeploy.parametersAS.json sc-2 solr-replica



#


#this goes in luncher script
#isFirstNode="true
args=("$@")
maxNumZoo=3 #${args[0]} #3
numShards=3 #${args[1]} #6
numNodes=3 #${args[2]}
replicationFactor=3 #higher=greater search performance(greater QPS).  so scale thie as capacity requires
maxShardsPerNode=9 #must be set high to account for first 1 with 1 node.  This controls distribution.  use formula to compute using activeNodes.
vNet=${args[0]}
pass=${args[1]}
#end launcher script

thisIp=`ip route get 8.8.8.8 | awk '{print $NF; exit}'`
zookeeperHome=/opt/zookeeper
zooDataDir=$zookeeperHome/data
solrHome=/var/solr/data
solrInstDir=/opt/solr
solrVersion=6.0.1





sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer



#install solr with script
cd /tmp
sudo apt-get -y install tomcat7 tomcat7-admin
#wget http://mirrors.sonic.net/apache/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz
#wget http://apache.spinellicreations.com/lucene/solr/$solrVersion/solr-$solrVersion.tgz
 wget https://archive.apache.org/dist/lucene/solr/$solrVersion/solr-$solrVersion.tgz


tar xzf solr-$solrVersion.tgz solr-$solrVersion/bin/install_solr_service.sh --strip-components=2
sudo bash ./install_solr_service.sh solr-$solrVersion.tgz -i /opt -d /var/solr -u solr -s solr -p 8983


 #service solr start
 #service solr stop

# tar -xvf zookeeper-3.4.8.tar.gz
# sudo mkdir -p /opt/zookeeper
# sudo rm -r /opt/zookeeper/*
# sudo mv zookeeper-3.4.8/* /opt/zookeeper/
# sudo rm -r $zooDataDir
# sudo mkdir -p $zooDataDir

sudo chown -R solr:solr $solrInstDir-$solrVersion
sudo chown -R solr:solr /opt/zookeeper


# In case Solr is installed, exit.
if [ -e /usr/solr/current/solr ]; then
    echo "Solr is already installed, exiting ..."
    exit 0
fi

#create mount for azure share
#get access keys from azure portal
sudo mkdir /mnt/solrsettings
sudo mount -t cifs //$vNet.file.core.windows.net/settings /mnt/solrsettings -o vers=3.0,user=$vNet,password=$pass,dir_mode=0777,file_mode=0777

#solrConfDir=/mnt/solrsettings/conf
sudo cp /mnt/solrsettings/solr.in.sh.replicas /etc/default/solr.in.sh
sudo sed -i -e "s/replica_ip_here/$thisIp/g" /etc/default/solr.in.sh

isZooNode=false

sudo chown -R solr:solr $solrInstDir-$solrVersion
sudo chown -R solr:solr /mnt/solrsettings



#start solr
let max=numShards+1
sudo service solr stop
sudo service solr start
  #replicate all shards to maintain balance
  echo 'creating replicas for all $shards'
  shardNum=1
  while true; do
     echo "Creating replica .... shard$shardNum-replica-$thisIp"
     curl "http://$thisIp:8983/solr/admin/cores?action=CREATE&name=shard$shardNum-replica-$thisIp&collection=products&shard=shard$shardNum"
     sleep 60
     let shardNum=shardNum+1
	if [ "$shardNum" -eq "$max" ]
  then
          break
  fi
  done
