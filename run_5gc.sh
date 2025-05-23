#!/bin/bash

docker run --rm -it \
  --name open5gs_5gc \
  --privileged \
  --env-file RAN/srsRAN_Project/docker/open5gs/open5gs.env \
  -p 9999:9999/tcp \
  -p 38412:38412/sctp \
  -p 2152:2152/udp \
  --net oran-icdcn \
  --ip 10.53.1.2 \
  srsran/open5gs:latest \
  5gc -c open5gs-5gc.yml
