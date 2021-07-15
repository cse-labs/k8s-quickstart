FROM alpine:latest

# start in /root
WORKDIR /root

# alpine doesn't have a "sleep forever" option
ENTRYPOINT ["/bin/bash", "-c", "sleep 999999999d"]

# copy the simple .profile
COPY .profile /root

# install our utilities
RUN apk add --no-cache curl redis mariadb-client jq nano bash py-pip && \
    pip3 install --upgrade pip setuptools httpie
