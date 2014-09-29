FROM registry.runnable.com/runnable/ansible_base

ENV REPO_BASE /repos

RUN mkdir $REPO_BASE && cd $REPO_BASE && \
  echo "Host github.com" > /root/.ssh/config && \
  echo "  StrictHostKeyChecking no" >> /root/.ssh/config && \
  git clone git@github.com:CodeNow/api.git && \
  git clone git@github.com:CodeNow/runnable-angular.git && \
  git clone git@github.com:CodeNow/mavis.git && \
  git clone git@github.com:CodeNow/devops-scripts.git && \
  mv ./devops-scripts/ansible/hosts /etc/ansible/hosts && \
  mv ./devops-scripts/ssh /root/.ssh

WORKDIR /repos/devops-scripts/ansible

CMD ansible-playbook
