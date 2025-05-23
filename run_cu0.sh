#!/bin/bash

docker run --rm -it \
  --name srscu0 \
  --privileged \
  --cap-add SYS_NICE \
  --cap-add SYS_PTRACE \
  -v /dev/bus/usb/:/dev/bus/usb/ \
  -v /usr/share/uhd/images:/usr/share/uhd/images \
  -v $(pwd)/RAN/entrypoint_0.sh:/tmp/entrypoint.sh \
  -v $(pwd)/RAN/cu_0.yml:/config/cu.conf \
  --net oran-icdcn \
  --ip 10.53.1.240 \
  srsran:split_8_zmq \
  bash -c 'chmod +x /tmp/entrypoint.sh && /tmp/entrypoint.sh && srscu -c /config/cu.conf'
