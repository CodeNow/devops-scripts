FROM node:{{ node_version }}

{% if npm_version is defined %}
RUN npm install npm@{{ npm_version }} -g
{% endif %}

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
{% if has_shrinkwrap is defined  and has_shrinkwrap %}
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

RUN rm /root/.ssh/id_rsa
RUN rm /root/.ssh/known_hosts

# Define default command.
CMD ulimit -c unlimited && /usr/local/bin/npm {{ npm_start_command | default('start') }}
