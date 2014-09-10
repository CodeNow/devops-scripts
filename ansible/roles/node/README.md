Role Name
========

Ansible Role to Install Docker on CentOS 6.5

Role Variables
--------------

```
docker_centos_packages:
 - { package: "docker" }
```

Example Playbook
-------------------------

    - hosts: docker-servers
      roles:
         - { role: docker-centos, 
                   tags: ["docker"] }

Author Information
------------------

# anandkumarpatel
###         #
