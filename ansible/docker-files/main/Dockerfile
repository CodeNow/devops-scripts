from runnable/ansible_base

#clone all repos
RUN mkdir /repos && \
  git clone git@github.com:CodeNow/api.git && \
  git clone git@github.com:CodeNow/runnable-angular.git && \
  git clone git@github.com:CodeNow/mavis.git && \
  git clone git@github.com:CodeNow/devops-scripts.git && \
  mv ./devops-scripts/ansible/hosts /etc/ansible/hosts && \
  mv ./devops-scripts/ssh /root/.ssh

CMD ansible-playbook
