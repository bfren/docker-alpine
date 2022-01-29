FROM alpine:3.15.0

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # set to 0 to disable additional log output
    BF_DEBUG=1

COPY ./overlay /
COPY ./ESH_BUILD /tmp/
COPY ./3.15/overlay /

RUN chmod +x /usr/local/bin/bf-install
RUN bf-install
