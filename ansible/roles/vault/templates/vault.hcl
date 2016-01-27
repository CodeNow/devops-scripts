backend "consul" {
  address = "{{ consul_host_address }}:{{ consul_api_port }}"
  path = "vault"
  advertise_addr = "http://{{ ansible_default_ipv4.address }}:8200"
}

listener "tcp" {
 address = "0.0.0.0:8200"
 tls_disable = 1
}
