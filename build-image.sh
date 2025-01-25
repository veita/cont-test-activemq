#!/bin/bash

set -ex

cd "${0%/*}"

ACTIVEMQ_VERSION="6.1.4"
ARCHIVE="apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz"

PORT_WEBUI=8161
PORT_AMQP=5672
PORT_MQTT=1883
PORT_STOMP=61613
PORT_WS=61614
PORT_TCP=61616

# NEW https://dlcdn.apache.org/activemq/
URL="https://dlcdn.apache.org/activemq/${ACTIVEMQ_VERSION}/${ARCHIVE}"

# OLD https://dlcdn.apache.org/activemq/
#URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ARCHIVE}"

cd tmp
[ -e ${ARCHIVE} ] || curl $URL -o ${ARCHIVE} || exit 1
cd ..

# TODO verify download


CONT=$(buildah from debian-multiservice:bookworm)

buildah copy $CONT setup/ /setup
buildah copy $CONT tmp/${ARCHIVE} /opt/archive.tar.gz
buildah copy $CONT services/ /services
buildah run $CONT /bin/bash /setup/setup.sh
buildah run $CONT rm -rf /setup

buildah config --workingdir '/' $CONT
buildah config --cmd '["/services/init.sh"]' $CONT

buildah config --port $PORT_WEBUI/tcp $CONT
buildah config --port $PORT_AMQP/tcp  $CONT
buildah config --port $PORT_MQTT/tcp  $CONT
buildah config --port $PORT_STOMP/tcp $CONT
buildah config --port $PORT_WS/tcp    $CONT
buildah config --port $PORT_TCP/tcp   $CONT

buildah config --author "Alexander Veit" $CONT
buildah config --label commit=$(git describe --always --tags --dirty=-dirty) $CONT

buildah commit --rm $CONT localhost/test-activemq:latest
buildah tag localhost/test-activemq:latest localhost/test-activemq:${ACTIVEMQ_VERSION}
