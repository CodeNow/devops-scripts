# Secrets

This directory should have the following files:

```
/docker-client
  id_rsa
  known_hosts
  ca.pem
  ${SERVICE_NAME} (api, khronos, etc.)
    cert.pem
    key.pem
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
