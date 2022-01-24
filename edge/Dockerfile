FROM alpine:edge

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # set to 0 to disable additional log output
    BF_DEBUG=1

COPY ./overlay /
COPY ./edge/overlay /

RUN chmod +x /usr/local/bin/bf-*
RUN bf-install
