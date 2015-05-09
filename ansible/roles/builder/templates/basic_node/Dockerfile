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
RUN npm install -g npm@{{ npm_version }} && \
    n {{ node_version }}

# Download Repo
RUN git clone -b {{ git_branch }} --single-branch {{ repo }}

WORKDIR /{{ name }}
{% if dockerfile_pre_install_commands is defined %}
{% for command in dockerfile_pre_install_commands %}
RUN {{ command }}
{% endfor %}
{% endif %}

RUN npm install --production

{% if dockerfile_post_install_commands is defined %}
{% for command in dockerfile_post_install_commands %}
RUN {{ command }}
{% endfor %}
{% endif %}

# Define default command.
CMD ["/usr/local/bin/npm", "start"]
