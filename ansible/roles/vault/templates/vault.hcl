backend "consul" {
  address = "{{ ansible_default_ipv4.address }}:8500"
  path = "vault"
  advertise_addr = "http://{{ ansible_default_ipv4.address }}:8200"
}

listener "tcp" {
 address = "0.0.0.0:8200"
 tls_disable = 1
}
