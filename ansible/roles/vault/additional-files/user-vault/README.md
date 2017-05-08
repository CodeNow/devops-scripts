# Configuring Vault

Vault is specifically setup to be manually setup. This is not automated for a reason.

The first time you setup vault we need to manually configure a bunch 
of things so we don't pass around the root token.

`vault init`

Grab the keys, put them in 1password

`vault unseal $key1`

`vault unseal $key2`

`vault unseal $key3`

Verify the vault unsealed

`vault auth $rootToken`

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

Take the response of this and save it in the configuration for the environment you want.

Create a new token for the docks, so they can create readonly tokens.

`vault token-create -policy="dock-user-creator" -ttl="8760h"`

Save that token as the dock-creator token

10ce7be2-e029-fa4e-834e-e8f5ee0f5ca8




This allows the vault user to create a new user!
vault write -f auth/token/create/organizations-readonly
