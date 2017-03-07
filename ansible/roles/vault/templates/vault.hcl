backend "consul" {
  advertise_addr = "http://{{ ansible_default_ipv4.address }}:{{ vault_port }}"
  address = "{{ ansible_default_ipv4.address }}:{{ consul_api_port}}"
  scheme = "http"
  path = "vault"
}

listener "tcp" {
  address = "0.0.0.0:{{ vault_port }}"
  tls_disable = 1
}

listener "tcp" {
  address = "0.0.0.0:{{ vault_ssl_port }}"
  tls_ca_file = "/opt/vault/server/ca.pem"
  tls_cert_file = "/opt/vault/server/cert.pem"
  tls_key_file = "/opt/vault/server/key.pem"
}

max_lease_ttl = "8760h"
