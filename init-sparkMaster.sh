#!/bin/bash
#
# Cloud-init script to get Spark Master up and running
#
SPARK_VERSION="1.5.0"
APACHE_MIRROR="apache.uib.no"
LOCALNET="192.168.0.0/24" #(IP of network topolgy, do change it according to your network)

# Firewall setup
ufw allow from $LOCALNET
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 4040:4050/tcp
ufw allow 7077/tcp
ufw allow 8080/tcp

# Dependencies
apt-get -y update
apt-get -y install openjdk-7-jdk

# Download and unpack Spark
curl -o /tmp/spark-$SPARK_VERSION-bin-hadoop1.tgz http://$APACHE_MIRROR/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop1.tgz
tar xvz -C /opt -f /tmp/spark-$SPARK_VERSION-bin-hadoop1.tgz
ln -s /opt/spark-$SPARK_VERSION-bin-hadoop1/ /opt/spark
chown -R root.root /opt/spark-$SPARK_VERSION-bin-hadoop1/*

# Configure Spark master
cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
sed -i 's/# - SPARK_MASTER_OPTS.*/SPARK_MASTER_OPTS="-Dspark.deploy.defaultCores=4 -Dspark.executor.memory=2G"/' /opt/spark/conf/spark-env.sh

# Make sure our hostname is resolvable by adding it to /etc/hosts
echo $(ip -o addr show dev eth0 | fgrep "inet " | egrep -o '[0-9.]+/[0-9]+' | cut -f1 -d/) $HOSTNAME | sudo tee -a /etc/hosts

# Start Spark Master with IP address of eth0 as the address to use
/opt/spark/sbin/start-master.sh -h $(ip -o addr show dev eth0 | fgrep "inet " | egrep -o '[0-9.]+/[0-9]+' | cut -f1 -d/)

