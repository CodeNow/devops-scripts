#
# api_main Dockerfile
# Author anandkumarpatel
##

# Pull base image.
FROM registry.runnable.com/runnable/api_base:latest

WORKDIR /

# Download API-Server Repo
RUN git clone -b {{ git_branch }} --single-branch git@github.com:CodeNow/api.git

WORKDIR /api
RUN npm install --production

# Expose port to Host
EXPOSE 3000

# Define default command.
CMD ["/usr/local/bin/npm", "start"]
