# Configuring Vault

Vault is specifically designed to be manually setup. This is not automated for a reason.

```
kubectl port-forward INSTERT_VAULT_ID 8300:8200
export VAULT_ADDR=http://localhost:8300
```

The first time you setup vault we need to manually configure a bunch
of things so we don't pass around the root token.

`vault init`

Grab the keys, put them in 1password

`vault unseal $key1`

`vault unseal $key2`

`vault unseal $key3`

Verify the vault unsealed

`vault auth`
Paste in the $rootToken


Now to setup the policies:

```
vault policy-write organizations-writeonly roles/vault/additional-files/user-vault/policies/organizations-writeonly.hcl
vault policy-write organizations-readonly roles/vault/additional-files/user-vault/policies/organizations-readonly.hcl
vault policy-write dock-user-creator roles/vault/additional-files/user-vault/policies/dock-user-creator.hcl
```

Now to setup the roles

`vault write auth/token/roles/organizations-readonly allowed_policies="organizations-readonly"`

Now to setup new token for starlord:

`vault token-create -policy="organizations-writeonly" -ttl="8760h"`

Take the response of this and save it in the configuration for the environment you want as the `starlord_vault_token`

This allows the vault user to create a new user using:
vault write -f auth/token/create/organizations-readonly
