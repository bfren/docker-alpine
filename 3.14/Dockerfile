FROM alpine:3.14.3

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # set to 0 to disable additional log output
    BF_DEBUG=1

COPY ./overlay /
COPY ./3.14/overlay /

RUN chmod +x /usr/local/bin/bf-install
RUN bf-install
