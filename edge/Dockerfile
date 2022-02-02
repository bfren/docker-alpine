FROM alpine:edge

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # set to 0 to disable additional log output
    BF_DEBUG=1 \
    # path to bf executables
    BF_BIN=/usr/bin/bf

ENV \
    # add bf executables to PATH
    PATH=${BF_BIN}:${PATH}

COPY ./overlay /
COPY ./ESH_BUILD /tmp/
COPY ./edge/overlay /

RUN chmod +x ${BF_BIN}/bf-install && bf-install
