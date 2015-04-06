FROM registry.runnable.com/runnable/node_base:latest

# Expose port to Host
EXPOSE {{ hosted_port }}

# setup node and npm versions
RUN npm install -g npm@{{ npm_version }} && \
    n {{ node_version }}

# Download Repo
RUN git clone -b {{ git_branch }} --single-branch {{ repo }}

WORKDIR /{{ name }}

RUN npm install --production

# Define default command.
CMD ["/usr/local/bin/npm", "start"]
