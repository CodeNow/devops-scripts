# Role Name

Ansible Role to Install Docker Client Certs on Ubuntu

## Manual Setup

Creating new docker client certs:
1. cd into this dir ```cd <roles/docker_client>```
2. ensure you have ca-key.pem here `roles/docker_client/ca-key.pem`
3. run cert generator ```sudo ./scripts/genClientCert.sh <app name> <server ip>```

## Author Information

anandkumarpatel
