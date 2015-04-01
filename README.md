devops-scripts
==============


Ansible provides a framework for our administration and deployment. It requires an organization for scripts and variables.  By design it uses SSH to connect to all hosts before it executes the actions. As such it can be run from any machine. All Ansible provided functionality is idempotent and it strongly encourage custom scripts match that standard.

Here is the organization of the files in `devops-scripts/ansible`

* `*-hosts` - Files naming all the servers
* `*.yml` - The top level ansible actions.  These files describe how a host has vars and roles executed on it. 
* `/group_vars` - yml files that define variables and values for your ansible scripts. This mostly maps one to one with machine types in AWS. They’re a key value map. 
* `/library` - Third party libraries and scripts. 
* `/roles` - A set of folders containing the ansible roles. A role defines the executable actions by ansible.  The center pieces is the `/tasks/main.yml`. It defines name actions and requirements. 
The role can have several sub folders.
  * `/handlers` - ??? 
  * `/defaults` - ???
  * `/meta` - contains dependencies
  * `/template` - templates for any files that need to be generate and delivered. 
