#!/bin/bash

set -exuo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy
apt-get install -qy git default-jdk-headless

# install and configure ActiveMQ
mkdir /opt/tmp
tar -C /opt/tmp -xzf /opt/archive.tar.gz
mv /opt/tmp/* /opt/activemq
rm /opt/archive.tar.gz
rmdir /opt/tmp

useradd -r -M -d /opt/activemq activemq
shopt -s dotglob
cp /etc/skel/* /opt/activemq
chown -R activemq:activemq /opt/activemq

sed -i 's|ACTIVEMQ_USER=""|ACTIVEMQ_USER="activemq"|g' /opt/activemq/bin/setenv
sed -i 's|<property name="host" value="127.0.0.1"/>|<property name="host" value="0.0.0.0"/>|g' /opt/activemq/conf/jetty.xml

# build https://github.com/veita/mqtt-timer.git
cd tmp
git clone https://github.com/veita/mqtt-timer.git
cd mqtt-timer
./gradlew build || exit 1
cp build/libs/mqtt-timer-all.jar /usr/local/bin/ || exit 1
rm -rf /root/.gradle
cd ..

# remove temporarily used packages
apt-get -qy purge git default-jdk-headless
apt-get install -qy default-jre-headless

# cleanup
source /setup/cleanup-image.sh
