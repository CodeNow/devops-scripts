FROM registry.runnable.com/runnable/{{ base_dockerfile }}:latest

# Copied from https://hub.docker.com/r/progrium/consul/~/dockerfile/
ADD https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

ADD https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip /tmp/webui.zip
RUN cd /tmp && unzip /tmp/webui.zip && mv dist /ui && rm /tmp/webui.zip

ADD ./config /config/

ADD ./check-http /bin/check-http
ADD ./check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500
VOLUME ["/data"]

ENV SHELL /bin/bash
# end copy

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

# Download Repo
RUN git clone -b {{ git_branch }} --single-branch {{ repo }} /{{ name }}

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

ENTRYPOINT ["/bin/consul", "agent", "-config-dir=/config"]
