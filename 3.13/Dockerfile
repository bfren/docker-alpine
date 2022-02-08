FROM alpine:3.13.7

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # debug log output
    #   0: disable
    #   1: enable
    BF_DEBUG=1 \
    # path to bf executables
    BF_BIN=/usr/bin/bf \
    # path to bf library executables
    BF_LIB=/usr/lib/bf

ENV \
    # add bf executables to PATH
    PATH=${BF_BIN}:${PATH}

COPY ./overlay /
COPY ./ESH_BUILD /tmp/
COPY ./3.13/overlay /

RUN chmod +x ${BF_BIN}/bf-install && bf-install

ENTRYPOINT [ "bf-init" ]
