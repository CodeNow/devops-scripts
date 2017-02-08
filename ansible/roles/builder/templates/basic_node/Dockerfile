FROM node:latest

{% if hosted_ports is defined %}
# Expose port to Host
EXPOSE {% for hosted_port in hosted_ports %}{{ hosted_port }} {% endfor %}
{% endif %}

{% if dockerfile_enviroment is defined %}
# Envs
{% for env in dockerfile_enviroment %}
ENV {{ env }}
{% endfor %}
{% endif %}

# setup node and npm versions
RUN npm install -g n@2.1.0
RUN n {{ node_version }} && npm install -g npm@{{ npm_version }}

WORKDIR /{{ name }}
{% if dockerfile_pre_install_commands is defined %}
{% for command in dockerfile_pre_install_commands %}
RUN {{ command }}
{% endfor %}
{% endif %}

RUN mkdir /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa
ADD known_hosts /root/.ssh/known_hosts
RUN chmod 600 /root/.ssh/id_rsa

# Add package.json from the current build context (`.` is the repo) second
ADD ./repo/package.json /{{ name }}/package.json

# Add shrinkwrap from the current build context (`.` is the repo) first
# If we change a non first-level dependency, this will break cache as expected
{% if has_shrinkwrap is defined %}
ADD ./repo/npm-shrinkwrap.json /{{ name }}/npm-shrinkwrap.json
{% endif %}

# install, should will skip if no package.json change
WORKDIR /{{ name }}
RUN npm install --production

# move the current build context (`.` is the repo) to /{{ name }}
ADD ./repo /{{ name }}

{% if dockerfile_post_install_commands is defined %}
{% for command in dockerfile_post_install_commands %}
RUN {{ command }}
{% endfor %}
{% endif %}

# Define default command.
CMD ulimit -c unlimited && /usr/local/bin/npm {{ npm_start_command | default('start') }} 
