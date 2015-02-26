#
# Khronos Dockerfile
#

# Pull base image.
FROM registry.runnable.com/runnable/khronos_base:latest

WORKDIR /

# Download Khronos Repo
RUN git clone git@github.com:CodeNow/khronos.git

WORKDIR /khronos
RUN npm install

CMD npm start