FROM registry.runnable.com/runnable/base:latest

RUN sudo apt-get install python
RUN sudo easy_install pip
RUN sudo pip install paramiko PyYAML jinja2 httplib2

WORKDIR /
RUN git git://github.com/ansible/ansible.git
WORKDIR /ansible
RUN source ./hacking/env-setup

#runnable repos for dockefiles
WORKDIR /
RUN git clone git@github.com:CodeNow/mavis.git
WORKDIR /
RUN git clone git@github.com:CodeNow/api.git
WORKDIR /
RUN git clone git@github.com:CodeNow/runnable-angular.git
WORKDIR /
RUN git clone git@github.com:CodeNow/krain.git

ADD . /playbooks