FROM registry.runnable.com/runnable/ansible_base

ENV REPO_BASE /repos

RUN mkdir $REPO_BASE
WORKDIR /repos

# clone repos for dockerfiles
RUN git clone git@github.com:CodeNow/api.git
RUN git clone git@github.com:CodeNow/runnable-angular.git
RUN git clone git@github.com:CodeNow/mavis.git
RUN git clone git@github.com:CodeNow/devops-scripts.git
# copy things into places
RUN mv ./devops-scripts/ansible/hosts /etc/ansible/hosts
RUN mv ./devops-scripts/ssh /root/.ssh

WORKDIR /repos/devops-scripts/ansible

CMD ansible-playbook
