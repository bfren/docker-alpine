FROM alpine:edge

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=1 \
    # add bf executables to PATH
    PATH=/usr/bin/bf:${PATH}

COPY ./overlay /
COPY ./ESH_BUILD /tmp/
COPY ./edge/overlay /

RUN chmod +x /usr/local/bin/bf-install && bf-install

ENTRYPOINT [ "bf-init" ]
