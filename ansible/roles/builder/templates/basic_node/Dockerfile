FROM registry.runnable.com/runnable/{{ base_dockerfile }}:latest

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
RUN n {{ node_version }} && npm install -g npm@{{ npm_version }}

{% if dockerfile_pre_install_commands is defined %}
{% for command in dockerfile_pre_install_commands %}
RUN {{ command }}
{% endfor %}
{% endif %}

# Add package.json from the current build context (`.` is the repo) first
ADD ./repo/package.json /{{ name }}/package.json

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
CMD ulimit -c unlimited && /usr/local/bin/npm {{ npm_start_command | default('start') }} > /var/log/{{ name }}.log 2>&1
