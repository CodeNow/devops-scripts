# Secrets

This directory should have the following files:

```
/docker-client
  id_rsa
  known_hosts
/certs
  ca-key.pem
  ca.pem
  ca.srl
  cert.pem
  key.pem
  pass
/domains
  /${DOMAIN}
    ca.pem
    cert.pem
    key.pem
    chained.pem
    dhparam.pem
```
