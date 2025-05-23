#!/bin/bash

docker run --rm -it \
  --name redis \
  -p 6379:6379 \
  --net oran-icdcn \
  --ip 10.24.0.1 \
  redis:latest
