#!/bin/bash
docker run -it --rm \
    --net host \
    -e LOCAL_UID=$(id -u $USER) \
    -e LOCAL_GID=$(id -g $USER) \
    -e USER=$USER \
    -e DISPLAY=$DISPLAY \
    -v $XAUTHORITY:/tmp/.XAuthority \
    -e XAUTHORITY=/tmp/.XAuthority \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /sys:/sys:ro \
    -v /opt/intelFPGA_lite:/opt/intelFPGA_lite \
    -v $(pwd):/root/TEP \
    tep:v1.0 \
    /bin/bash -c "cd /root/TEP/lcc && make all install && cd .. && /bin/bash" \
