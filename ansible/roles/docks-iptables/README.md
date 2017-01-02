iptables
===========

This role applies the iptables on the server and also add /etc/firewall.conf which loads on system startup.

__NOTE__: Please make appropriate changes in template `firewall.conf.j2` which is loaded only on system startup through `iptable-save` command. This template is stored at `/etc/firewall.conf` and loaded by `/etc/rc.local`

Role Variables
--------------

The variables that can be passed to this role and a brief description about them are as follows.

- __iptables_rule__ : list of all iptable rules to apply. Its entry is made to `/etc/firewall.conf` file also.

Author Information
------------------

### varun.palekar@stackexpress.com
### github: varunpalekar
### stackexpress
