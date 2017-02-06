disable_mlock = true

backend "s3" {
  bucket = "runnable.vault.grizzly"
  access_key = "AKIAIS2HMUM2REGVTVIQ"
  secret_key = "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"
  region = "us-west-2"
}

listener "tcp" {
  address = "127.0.0.1:31836"
  tls_disable = 1
}
