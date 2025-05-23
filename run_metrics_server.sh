#!/bin/bash

docker run --rm -it \
  --name metrics_server \
  -e PORT=${METRICS_SERVER_PORT} \
  -e BUCKET=${DOCKER_INFLUXDB_INIT_BUCKET} \
  -e TESTBED=default \
  -e URL=http://${DOCKER_INFLUXDB_INIT_HOST}:${DOCKER_INFLUXDB_INIT_PORT} \
  -e ORG=${DOCKER_INFLUXDB_INIT_ORG} \
  -e TOKEN=${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
  -p 55555:${METRICS_SERVER_PORT}/udp \
  --net oran-icdcn \
  --ip 10.40.1.4 \
  srsran/metrics_server
