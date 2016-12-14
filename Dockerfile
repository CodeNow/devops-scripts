FROM ubuntu:14.04

RUN echo "===> Adding Ansible's prerequisites..."   && \
    apt-get update -y            && \
    DEBIAN_FRONTEND=noninteractive  \
        apt-get install --no-install-recommends -y -q  \
                build-essential                        \
                python-pip python-dev python-yaml      \
                libxml2-dev libxslt1-dev zlib1g-dev    \
                git                                    \
                curl                                   \
                sshpass openssh-client              && \
    pip install --upgrade pyyaml jinja2 pycrypto && \
    curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - && \
    apt-get install -y nodejs

RUN git clone git://github.com/ansible/ansible.git --recursive /opt/ansible
RUN cd /opt/ansible && \
    git checkout v2.1.3.0-1 && \
    git submodule update --init --recursive && \
    bash -c 'source ./hacking/env-setup'

ENV PATH        /opt/ansible/bin:$PATH
ENV PYTHONPATH  /opt/ansible/lib:$PYTHONPATH
ENV MANPATH     /opt/ansible/docs/man:$MANPATH

ADD ./ssh /root/.ssh

ADD ./ansible/ /ansible
RUN cd /ansible && npm install

ADD ./deployer/ /deployer
RUN cd /deployer && npm install

WORKDIR /deployer
ENTRYPOINT eval `ssh-agent`; ssh-add /root/.ssh/id_rsa; bash
CMD npm start
