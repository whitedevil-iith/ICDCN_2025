#!/bin/bash

docker run --rm -it \
  --name influxdb \
  -v influxdb-storage:/var/lib/influxdb2:rw \
  --env-file .env \
  -p 8086:${DOCKER_INFLUXDB_INIT_PORT} \
  --net oran-icdcn \
  --ip 10.40.1.5 \
  influxdb:${DOCKER_INFLUXDB_VERSION}
