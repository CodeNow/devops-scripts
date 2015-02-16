#
# Khronos Dockerfile
#

# Pull base image.
FROM registry.runnable.com/runnable/base:latest

# Node.js @ 0.10.35
# npm     @ 2.2.0

RUN wget http://nodejs.org/dist/v0.10.35/node-v0.10.35.tar.gz \
  && tar xvf node-v*.tar.gz \
  && rm -rf node-v*.tar.gz \
  && cd node-v0.10.35 \
  && ./configure \
  && make -j16 \
  && make install \
  && npm install -g npm@2.2.0

WORKDIR /

# Download Khronos Repo
RUN git clone git@github.com:CodeNow/khronos.git

WORKDIR /khronos
RUN npm install

CMD npm start
