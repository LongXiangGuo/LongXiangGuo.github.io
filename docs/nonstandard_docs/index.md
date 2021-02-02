---
layout: default
title: Non-standard Documentation
nav_order: 8
has_children: false
---

# Non-standard Documentation
This page is meant to capture documentation for any services or APIs that are outside our normal documentation process

## FG Connected Web API Interface Specification
The [Connected Web API Inteface Specification]({{site.baseurl}}/assets/docs/Interface-Specification_REST_API_2017-02-02.pdf) describes the API used by the Mobile 2.0 vehicle presentation microservice.  This API is exposed by the internal BMW NPM package [web-api](http://btcnpmregistry.centralus.cloudapp.azure.com/#/detail/@bmw/web-api). This API will be deprecated at the end of 2019 but is here as a resource to understand what the APIs are and what their expected behavior should be.

### Remote History
For Remote History, please look at the interfaces "serviceExecutionStatus", "serviceExecutionHistory", and "hideServiceExecutionHistory" interfaces.

## CDP Documentation

Swagger documentation for CDP can be found [here](https://tst-b2vii.muc:9650/cdp/rest/swagger-ui/index.html)

## iOS APNS Auth Key Storage Retrieval

We have an APNS Auth Key created under the Bayerische Motoren Werke (enterprise) apple developer account. This accounts for all of our distribution builds. This is stored at:

`secret/mobile20/apns_certs/key`

- Auth Key ID: `X297BVUMZM`
- Dev Team ID: `2K6X2XEF3Z`

To retrieve this token: 

`vault kv get -field=key secret/mobile20/apns_certs | base64 --decode > AuthKey_[KEY_ID].p8`


To update this token, you can follow the following example: 

`vault kv put secret/mobile20/apns_certs/ key=$(cat AuthKey_[KEY_ID].p8 | base64)`
