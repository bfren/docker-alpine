FROM alpine:3.13.7

ARG BF_IMAGE
ARG BF_VERSION

ENV \
    # set to 0 to disable additional log output
    BF_DEBUG=1

COPY ./overlay /
COPY ./3.13/repositories /etc/apk/repositories

RUN chmod +x /usr/local/bin/bf-*
RUN bf-install
