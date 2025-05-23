#!/bin/bash

docker run --rm -it \
  --name srsue0 \
  --device /dev/net/tun \
  --cap-add SYS_NICE \
  --cap-add SYS_RESOURCE \
  --cap-add NET_ADMIN \
  --cap-add IPC_LOCK \
  --env-file .env \
  -v $(pwd)/UE/ue_zmq.conf:/configs/ue.conf \
  -v /dev/null:/tmp/ue.log \
  --net oran-icdcn \
  --ip 10.53.1.251 \
  srsue:split_8_zmq \
  bash -c '/srsue_4G/srsue/src/srsue /configs/ue.conf'
