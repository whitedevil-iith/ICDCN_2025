#!/bin/bash

docker run --rm -it \
  --name grafana \
  -v grafana-storage:/var/lib/grafana:rw \
  --env-file .env \
  -p 3300:${GRAFANA_PORT} \
  --net oran-icdcn \
  --ip 10.40.1.6 \
  srsran/grafana
