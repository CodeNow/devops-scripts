packer
======

# Packer Notes

Packer is a hashicorp tool to read a configuration template in JSON and produce an Amazon Machine Image.

We further abstract packer builds by using the Jinja2 substitution macro language to interpolate environment variables into the packer templates via Ansible.
