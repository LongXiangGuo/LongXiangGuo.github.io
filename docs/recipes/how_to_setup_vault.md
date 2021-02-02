---
layout: default
title: How To Set Up Vault and Add API Keys
parent: Recipes
nav_order: 6
---

# How To Set Up Vault and Add API Keys

## Authenticate with Vault

1. Export Vault Address in your terminal: `export VAULT_ADDR=https://btcvault.westeurope.cloudapp.azure.com/`
2. Login to Mobile 2.0 Vault: `vault login -method=userpass username=btcmobile20user` _Get password from Mobile 2.0 member_
3. Export Vault Token: `export VAULT_TOKEN=<YOUR_TOKEN>`

## Adding Keys to Vault

Once you have authenticated your machine with Vault, you can now access the keys for each repository.

**Retrieve Keys**: `vault kv get secret/mobile20/destination_composite_service/na_dly`

After retrieving the keys, copy/paste them into a blank document, then add your new key/val pairing. Then you will need to `put` all the `key_name=key_value` separated by a space.

**Put Keys**: `vault kv put secret/mobile20/destination_composite_service/na_dly key_name1=key_value1, key_name2=key_value2` etc.

Please note that when you run `put` it replaces everything existing, so in addition to your new key/val, you need to add the old ones as well.
