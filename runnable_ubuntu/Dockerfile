FROM ubuntu

# Update aptitude with new repo
RUN apt-get update

# Install software
RUN apt-get install -y git

# Make ssh dir
RUN mkdir /root/.ssh/

# Copy over private key,
ADD id_rsa /root/.ssh/id_rsa

# add .ssh config file
ADD config /root/.ssh/config

# set correct permissions
RUN chmod 600 /root/.ssh/id_rsa