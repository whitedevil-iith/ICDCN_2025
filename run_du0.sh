#!/bin/bash

docker run --rm -it \
  --name srsdu0 \
  --privileged \
  --cap-add SYS_NICE \
  --cap-add SYS_PTRACE \
  -v /dev/bus/usb/:/dev/bus/usb/ \
  -v /usr/share/uhd/images:/usr/share/uhd/images \
  -v $(pwd)/RAN/du_zmq.conf:/config/du.conf \
  -v $(pwd)/RAN/wait_for_cu_starting.sh:/config/wait_for_cu_starting.sh \
  --net oran-icdcn \
  --ip 10.53.1.250 \
  srsran:split_8_zmq \
  bash -c 'srsdu -c /config/du.conf'
