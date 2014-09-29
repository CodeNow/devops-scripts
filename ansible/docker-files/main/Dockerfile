from runnable/ansible_base

#clone all repos
ENV REPO_BASE /repos

RUN mkdir $REPO_BASE && cd $REPO_BASE && \
  git clone git@github.com:CodeNow/api.git && \
  git clone git@github.com:CodeNow/runnable-angular.git && \
  git clone git@github.com:CodeNow/mavis.git && \
  git clone git@github.com:CodeNow/devops-scripts.git && \
  mv ./devops-scripts/ansible/hosts /etc/ansible/hosts && \
  mv ./devops-scripts/ssh /root/.ssh

WORKDIR /repos/devops-scripts/ansible

CMD ansible-playbook
