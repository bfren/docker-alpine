FROM alpine:3.13.7

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # path to bf executables
    BF_BIN=/usr/bin/bf \
    # set to 0 to disable additional log output
    BF_DEBUG=1 \
    # add bf executables to PATH
    PATH=/bin:/usr/bin:${BF_BIN} \

COPY ./overlay /
COPY ./ESH_BUILD /tmp/
COPY ./3.13/overlay /

RUN chmod +x ${BF_BIN}/bf-install
RUN bf-install
