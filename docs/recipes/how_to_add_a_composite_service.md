---
layout: default
title: How To Add a Composite Service
parent: Recipes
nav_order: 9
---

# How To Add a Composite Service

1. Create a Git repository via Runtime [github-config](https://code.connected.bmw/runtime/github-config)

2. Set up the Jenkins pipeline via Runtime [jenkins-jobs-edge](https://code.connected.bmw/runtime/jenkins-jobs-edge)

3. Add secrets to vault: `vault kv put secret/{org}/{name_of_composite_service}/{env}` (ex. `vault kv put secret/eadrax/vehicle_composite_service/na_dly`)

4. Deploy the repository to the various clusters via Runtime [tf-cluster-apps](https://code.connected.bmw/runtime/tf-cluster-apps)

**_Wait for step 1 to be completed and merged before merging your jenkins-job and tf-cluster-apps PR's from steps 2 and 4_**

## Developer setup for existing services

### Running a service locally

1. Clone the composite service of interest from github and run `npm install` to install all dependencies. If `npm install` is stuck, try running: `sudo npm i --unsafe-perm --verbose -g @angular/cli`, see [GitHub Issue 8367](https://github.com/angular/angular-cli/issues/8367).

2. `src/config.ts` defines configurations that are important when running the service locally. 
    
    Example - to run the service for NA, set the `microserviceConfiguration.environment()` as `Region.NorthAmerica`.

3. `src/config.ts` also lists all the env variables the service consumes. These env variables are read from the `src/.env` file
when the service is run locally.

4. Ensure all process.env.variables in the config file have entries in the `src/.env` file.

5. The variables typically include URLs of services, API key names and values. Change these values before running the service locally. 
    
    Example - NA INT variable values defined for the user-composite-service can be found in [tf-cluster-apps](https://code.connected.bmw/runtime/tf-cluster-apps/blob/8232873c40ccf35308b8b54b6763df7edad51538/naint/apps/user-composite-service.tf) in the environment section.

    ```
    environment = {
        CURRENT_ENV                  = "int_na"
        CONTEXT_API_BASE_URL         = "http://mobility-graph-api.service.consul/context"
        FG_GATEWAY_BASE_URL          = "http://fg-gateway.service.consul"
        MOBILITY_GRAPH_BASE_URL      = "http://mobility-graph.service.consul"
        MOBILITY_GRAPH_API_KEY_VALUE = "${data.vault_generic_secret.user_composite_service.data["mobility_graph_api_key_value"]}"
    }
    ```

    - These values are resolved in the mesh, typically from consul (for URLs) and vault (for API keys/values.)

    - From consul:
        - If the variable has a suffix `service.consul` then the value will be defined in the corresponding mesh-config. 
        
        - For example, the user-composite-service has an env variable in tf-cluster-apps defined as
        `FG_GATEWAY_BASE_URL = "http://fg-gateway.service.consul"`. 
        
        - The prefix `fg-gateway` can be looked up in the corresponding [mesh-config file](https://code.connected.bmw/runtime/tf-mesh-config/blob/3091107495b197b239bb68f560b345f77318fb21/consul/naint/system-gwy-ext-config.tf#L61) as `api.bmwgroup.us`

    - From vault: 
        - If the tf-cluster-app env variable is shown to be read from vault, access this value from vault after setting it up and logging in as exaplined above and using the command `vault kv get` for the service and variable of interest. 

        - For example, for NA INT the user-composite-service's vault path is defined in [tf-cluster-apps](https://code.connected.bmw/runtime/tf-cluster-apps/blob/8232873c40ccf35308b8b54b6763df7edad51538/naint/apps/user-composite-service.tf#L2) as `secret/mobile20/user_composite_service/na_int`

        - To access the value of `MOBILITY_GRAPH_API_KEY_VALUE` use the command: 
        
            `vault kv get secret/mobile20/user_composite_service/na_int`

6. Update these env values to the appropriate values for the environment you intend to run in the `src/.env` file and then run `npm run start:dev`. The service will run now and the swagger can be accessed at `http://localhost:8080/docs`. Logs should show on your console. 

7. To test/debug the service you can set break points in the IDE and trigger these break points by executing the api call via swagger/postman.

8. Example postman call to access the `/api/v1/presentation/users` API from the user-composite-service running locally: 

    ```
    curl -X GET \
  http://localhost:8080/api/v1/presentation/users \
  -H 'accept: application/json' \
  -H 'authorization: Bearer yVzs9kCtpZDfMQ2Tm0tAyEKuF1cAIBOl' \
  -H 'x-usid: e4a9b106-2533-42d4-8cde-e606bb7850aa'
  ```

9. Example postman call to access the same API via the service mesh : 

    ```
    curl -X GET \
  https://btcnaint.centralus.cloudapp.azure.com/svc/user-composite-service/api/v1/presentation/users \
  -H 'Authorization: Bearer G3Gyf13Cmh1tXVz8PAEFmmrtokmkSn0E' \
  -H 'Postman-Token: 9b66e6d1-00f3-42e2-baba-d82c1f5ed85c' \
  -H 'accept: application/json' \
  -H 'cache-control: no-cache' \
  -H 'x-usid: e4a9b106-2533-42d4-8cde-e606bb7850aa'
  ```
  If postman shows an error on execution and you rely on Proxifier for your proxy settings, make sure Postman's proxy settings are all turned off so the traffic is routed through Proxifier. 


