#
# node_base Dockerfile
#
# Pull base image.
FROM registry.runnable.com/runnable/base:latest

# Node.js @ 0.10.28
# npm     @ 2.1.18
# curl
# lsof
# sass
# ruby

WORKDIR /

ENV PATH=./node_modules/.bin:$PATH
# HACK FOR SASS
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup | sudo bash - && \
    apt-get install -y nodejs lsof ruby && \
    locale-gen en_US.UTF-8 && \
    gem install sass && \
    npm install -g n && \
    npm install -g npm@2.1.18 && \
    n 0.10.28