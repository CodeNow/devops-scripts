disable_mlock = true

backend "s3" {
  bucket = "runnable.vault.grizzly"
  access_key = "AKIAJWTGYN3FCQELH5VQ"
  secret_key = "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"
  region = "us-west-2"
}

listener "tcp" {
  address = "127.0.0.1:65240"
  tls_disable = 1
}
