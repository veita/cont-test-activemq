FROM openjdk:11-jre


ENV ACTIVEMQ_VERSION 5.17.2

ENV ARCHIVE apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz
ENV PORT_TCP=61616 PORT_AMQP=5672 PORT_STOMP=61613 PORT_MQTT=1883 PORT_WS=61614 PORT_WEBUI=8161

# NEW https://dlcdn.apache.org/activemq/
ENV URL https://dlcdn.apache.org/activemq/${ACTIVEMQ_VERSION}/${ARCHIVE}

# OLD https://dlcdn.apache.org/activemq/
#ENV URL https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ARCHIVE}


RUN curl $URL -o ${ARCHIVE}

# TODO verify download

RUN tar xzf ${ARCHIVE} -C /opt && \
    mv /opt/* /opt/activemq && \
    useradd -r -M -d /opt/activemq activemq && \
    chown -R activemq:activemq /opt/activemq && \
    sed -i 's|<property name="host" value="127.0.0.1"/>|<property name="host" value="0.0.0.0"/>|g' /opt/activemq/conf/jetty.xml

USER activemq

WORKDIR /opt/activemq
EXPOSE $PORT_TCP $PORT_AMQP $PORT_STOMP $PORT_MQTT $PORT_WS $PORT_WEBUI

CMD ["/bin/sh", "-c", "bin/activemq console"]
