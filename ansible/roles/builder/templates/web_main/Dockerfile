#
# web_main Dockerfile
# used to install deps and starting application
# nothing here can be cached
#

FROM registry.runnable.com/runnableio/web_base:latest

# Download Runnable-web Repo
WORKDIR /

RUN git clone -b {{ git_branch }} --single-branch git@github.com:CodeNow/runnable-angular.git

WORKDIR /runnable-angular

ENV API_HOST //api.{{ domain }}
ENV USER_CONTENT_DOMAIN {{ user_content_domain | default("runnableapp.com") }}
ENV NODE_ENV production
RUN npm install --production
RUN npm run gruntDeploy

# Expose port to Host
# Expose port for https
EXPOSE 3000 443

# Define default command.
CMD ["/usr/local/bin/npm", "start"]
