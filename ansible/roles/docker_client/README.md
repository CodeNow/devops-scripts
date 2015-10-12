# Role Name

Ansible Role to Install Docker Client Certs on Ubuntu

## Manual Setup

Creating new docker client certs:
1. cd into this dir ```cd <roles/docker_client>```
2. ensure you have ca-key.pem here `roles/docker_client/ca-key.pem`
3. run cert generator `sudo ./scripts/genClientCert.sh`
4. output files we want are `<name>-key.pem` and `<name>-cert.pem`
5. create folder for these new certs based on app name ```mkdir <name>```
6. move keys into folder ```mv ./<name>-key.pem ./<name>/key.pem && mv ./<name>-cert.pem ./<name>/cert.pem```

## Author Information

anandkumarpatel
