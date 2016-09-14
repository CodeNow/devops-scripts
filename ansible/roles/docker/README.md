# Role Name

Ansible Role to Install Docker on Ubuntu

## Manual Setup

*Important: You must set up the following certificates on new boxes manually (for now):*

For the Docker daemon:
- `/etc/ssl/docker/`:
  - `ca.pem`: CA certificate that also signed the client keys
  - `cert.pem`: Docker _server_ certificate
  - `key.pem`: Key used to sign the Docker server certificate

For the Docker client:
- `/home/ubuntu/.docker/`:
  - `ca.pem`: CA certificate that also signed the client keys (should be the same one as in `/etc/ssl/docker`)
  - `cert.pem`: Docker _client_ certificate
  - `key.pem`: Key used to sign the Docker client certificate

To ensure docker verifies the local client, you need to either pass `--tlsverify` to the docker command, or you need to set `DOCKER_TLSVERIFY=1` in the environment.

## Role Variables

```
docker_centos_packages:
 - { package: "docker" }
```

## Example Playbook

    - hosts: docker-servers
      roles:
         - { role: docker-centos,
                   tags: ["docker"] }

## Author Information

anandkumarpatel
