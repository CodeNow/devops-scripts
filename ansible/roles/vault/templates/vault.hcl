backend "consul" {
  advertise_addr = "http://{{ ansible_default_ipv4.address }}:8200"
  address = "{{ ansible_default_ipv4.address }}:{{ consul_https_port }}"
  scheme = "https"
  path = "vault"
  tls_ca_file = "/opt/vault/client-consul/ca.pem"
  tls_cert_file = "/opt/vault/client-consul/cert.pem"
  tls_key_file = "/opt/vault/client-consul/key.pem"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

listener "tcp" {
  address = "0.0.0.0:8201"
  tls_ca_file = "/opt/vault/server/ca.pem"
  tls_cert_file = "/opt/vault/server/cert.pem"
  tls_key_file = "/opt/vault/server/key.pem"
}

max_lease_ttl = "8760h"
