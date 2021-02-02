---
layout: default
title: How to Renew the SSL Certificate for btcnpmregistry
parent: Recipes
nav_order: 3
---

# How to Renew the SSL Certificate for btcnpmregistry

## Temporarily expose the registry to the public

- Login to the [azure portal](https://portal.azure.com)
- Search for and select the `npmregistry-nsg` (network security group)
- Select `Inbound Security Rules`
- Click `Add`
- Add a new rule called `tmp` which exposes port `80` from any IP
- Click `Save`

## Renew the Certificate

### ssh into the registry VM

```sh
ssh btcm5@btcnpmregistry.centralus.cloudapp.azure.com
# pwd: IL0v3JS!1234
```

### Stop the npm server

```sh
sudo /etc/init.d/verdaccio stop
```

To ensure the npm server has been stopped:

```sh
sudo lsof -t -i:80
```

If the above command returns any process ID's, then you need to explicitly kill them with the following command:

```sh
sudo kill -9 processIDGoesHere
```

### Renew the Cert

```sh
sudo /home/btcm5/ssl-auto-renew.sh
```

### Start the npm server

```sh
sudo /etc/init.d/verdaccio start
```

## Close off the registry from the public

- Remove the `tmp` rule added earlier.
