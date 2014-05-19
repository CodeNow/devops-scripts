#
# api_repo_main Dockerfile
#
#
# Pull base image.
FROM sandipsingh/api_repo_base
RUN apt-get update 
RUN eval $(ssh-agent) > /dev/null && ssh-add /.ssh/id_rsa
# Download API-Server Repo
RUN git clone git@github.com:CodeNow/api-server.git 

WORKDIR api-server RUN npm install 
WORKDIR api-server make 
WORKDIR api-server npm build 

# Define default command.
CMD ["NODE_ENV=staging pm2 start server.js -n API-Server", "pm2 logs"]

