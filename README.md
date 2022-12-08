# ActiveMQ container with pre-defined topics

## Topics
* `timer.daily` - one event per day
* `timer.hourly` - one event per hour
* `timer.minutely` - one event per minute
* `timer.secondly` - one event per second
* `timer.hundredmsly` - ten events per second

## Exposed ports
* WEBUI 8161 (user `admin`, password `admin`)
* AMQP 5672
* MQTT 1883
* STOMP 61613
* WS 61614
* TCP 61616

## Building the base image

```bash
git clone https://github.com/veita/cont-debian-multiservice debian-multiservice
cd debian-multiservice
./build-image.sh
```

## Building the image

```bash
git clone https://github.com/veita/cont-test-activemq.git test-activemq
cd test-activemq
./build-image.sh
```

## Running the container

Run the container, e.g. with

```bash
podman run --name amq --hostname amq --detach --rm --memory 128M -p 8161:8161 -p 1883:1883 -p 61616:61616 localhost/test-activemq:latest
```

