FROM registry.runnable.com/runnable/{{ base_dockerfile }}:latest

{% if hosted_ports is defined %}
# Expose port to Host
EXPOSE {% for hosted_port in hosted_ports %}{{ hosted_port }} {% endfor %}
{% endif %}

{% if dockerfile_environment is defined %}
# Envs
{{ dockerfile_environment }}
{% endif %}

# setup node and npm versions
RUN npm install -g n@2.1.0
RUN n {{ node_version }} && npm install -g npm@{{ npm_version }}

{% if redis_ca_cert_path is defined %}
# Redis CA CERT
ADD ./ssl/redis/ca.pem {{ redis_ca_cert_path }}
{% endif %}

{% if tls_service is defined %}
# TLS Client CERT
COPY ./{{ tls_service }}-client /opt/ssl/{{ tls_service }}-client
{% endif %}

{% if docker_client_certs is defined %}
# Docker certs for {{ name }}
COPY ./ssl /etc/ssl
{% endif %}

{% if nginx_conf is defined %}
COPY ./nginx /etc/nginx
{% endif %}

# ECONNRESET error work-aroute
RUN npm config set strict-ssl false

{% if dockerfile_pre_install_commands is defined %}
{% for command in dockerfile_pre_install_commands %}
RUN {{ command }}
{% endfor %}
{% endif %}

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
