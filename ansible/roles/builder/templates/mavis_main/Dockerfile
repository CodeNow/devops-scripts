#
# mavis_main Dockerfile
# Author anandkumarpatel
##

# Pull base image.
FROM registry.runnable.com/runnableio/mavis_base:latest

WORKDIR /

# Download Repo
RUN git clone git@github.com:CodeNow/mavis.git

WORKDIR /mavis
RUN npm install --production

# Expose port to Host
EXPOSE 3000

# Define default command.
CMD ["/usr/local/bin/npm", "start"]
