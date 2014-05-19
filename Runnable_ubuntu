#
# RUNNABLE_UBUNTU Dockerfile
#
#
# Pull base image.
FROM ubuntu:12.04
RUN apt-get update 
RUN apt-get install -y build-essential wget make git
RUN apt-get update 
#ssh_key 
RUN mkdir -p /.ssh
RUN mkdir -p /root/.ssh
ADD id_rsa /.ssh/id_rsa
ADD id_rsa.pub /.ssh/id_rsa.pub
RUN chmod 400 /.ssh/id_rsa 
RUN chmod 400 /.ssh/id_rsa.pub
ADD config /.ssh/config
ADD known_hosts /root/.ssh/known_hosts
RUN chmod 600 /root/.ssh/known_hosts

# ssh-key add Permanently 
RUN git clone https://github.com/wwalker/ssh-find-agent
RUN echo "source /ssh-find-agent/ssh-find-agent.bash" >> /root/.bashrc
RUN echo "set_ssh_agent_socket" >> /root/.bashrc
RUN echo "ssh-add /.ssh/id_rsa" >> /root/.bashrc
RUN chmod +x /ssh-find-agent/ssh-find-agent.bash
RUN eval $(ssh-agent) > /dev/null && ssh-add /.ssh/id_rsa

# Define default command.
# CMD ["git"]
