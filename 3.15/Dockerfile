FROM alpine:3.15

ENV \
    # set to 0 to disable additional log output
    BF_DEBUG=1

COPY ./overlay /
COPY ./3.14/repositories /etc/apk/repositories

RUN chmod +x /usr/local/bin/bf-*
RUN bf-install
