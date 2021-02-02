---
layout: default
title: Use Case
parent: Architecture as Code
grand_parent: Architecture
nav_order: 1
---

# Use case
In this section, it describes the creation of a real system "omcChargingHistoryComposite" in the context of the byproduct "eMobility" within the product "omc".

This example seeks to portray a more complex situation in the "omc" product where the subproduct does not yet exist.

Thus, the first step consists of the creation of the system, followed by the creation of the subproduct and the addition of the subproduct in the product "omc".

This process is finalized by connecting Connected App 2.0 to its BFFs.

Before you start specifying your architecture in Compass, you need some technical configuration of the development environment that you can see at the following link: [Compass - Technical Setup](https://atc.bmwgroup.net/confluence/display/CDARCH/Compass+-+Technical+Setup).

* [Create a System](#create-a-system)
* [Add Components to System](#add-components-to-system)
* [Add System to Subproduct](#add-system-to-subproduct)
* [Add Subproduct to Product](#add-subproduct-to-product)
* [Connected App 2.0 to BFFs](#connected-app-20-to-bffs)

## Create a System
To define a new System is necessary to find the folder of the product or subproduct to which the System belongs and create a new Typescript file inside it.

To help in the definition of the System name and context we should check in [this link](https://atc.bmwgroup.net/confluence/display/OPCC/OMC+Architecture+and+Services+Chicago) if we already have defined the System we need. 

In the example concerned, the system is found in the shared link and it is confirmed that it is to be included under the product "omc", however, the "eMobility" subproduct does not exist. For this reason, you start by creating a new folder within the "omc" product with the name of the subproduct "eMobility". The system file with the same system name "omcChargingHistoryComposite.ts" is then created.

Every file is automatically a Typescript module. If a module needs something from other models could import them using the "import" keyword.

It's possible to define which parts of the module are visible by other modules and which are not though the "export" keyword. Everything it's declare with "export" can be used by other modules.

To start to create a new System is necessary to import the "System" interface.
```typescript
import {System, InterfaceType} from"../../../../../architecture"
```
Now, we can create a new instance of the `System` class and assign it to a new exported variable.
```typescript
export const omcChargingHistoryCompositeSystem = new System('CHC','Charging History Composite')
    .withAppId('APP-17630')
    .withDescription('Provides an interface to manage charging history and private charging topics from core services to mobile App.')
```    
The first parameter is a globally unique ID of the system (e.g. "CHC"), the second one is a descriptive name (e.g. "Charging History Composite").

How the BFF and core services of the Mobile 2.0 are including inside the OMC product, should be specified the OMC APP-ID "APP-17630" by invoking the method "withAppId" on the system with that parameter value.

In addition, should be provided a concise description with the "withDescription" method. The description should summarize what the purpose of the system is, so that others can roughly understand it (e.g. "Provides an interface to manage charging history and private charging topics from core services to mobile App.").

## Add Components to System
Under the Charging History Composite system, several BFFs and core services with dependencies on other components have been developed. In this section, you want to describe the creation of a BFF service (e.g. "Private Charging Tariffs Composite") and a core Service (e.g. "Private Charging Tariffs") with their dependencies.

Since BFF depends on core Service, the creation of the "Private Charging Tariffs" microservice begins.

```typescript
export const omcPrivateChargingTariffsService = omcChargingHistoryCompositeSystem.createMicroservice('eMob-PCT')       
    .withDescriptiveName('eMobility - Private Charging Tariffs')
    .withDescription('Provides and store the tariffs for private charging sessions based on the begin and end time of charging, the costs and cost savings can be calculated and displayed for charging history.')   
    .withDocumentationUrl('https://code.connected.bmw/emobility/private-charging-tariffs-service');
```
That we export the variable "eMob-PCT" so that it is available for other modules. The first parameter 'eMob-PCT' is quite important here and refer to the Microservice ID.

The section "Compass microservice ID name convention" describes the way to define the microservice ID for the core services "Mobile 2.0".

Microservice ID documentation
{: .label .label-blue }
---
> The [Application List page](https://compass.bmwgroup.net/archascode/#/report/applicationlist) update process is automatic and triggered when integrating PR into master.

> No manual update is required on the Application list page to update the microservice id.

---

Once the microservice is developed in REST then a REST API is created using the "CreateRestApi" method with the API Id (e.g. "bmw-omc-emobpct-privatechargingtariffs"), the API version (e.g. "1.0") and a description of it (e.g. "OMC Private Charging Tariffs Rest API"). To define API id, you should refer to the "API ID definition" section.

```typescript
const omcPrivateChargingTariffsRestApi = omcPrivateChargingTariffsService.createRestApi('bmw-omc-emobpct-privatechargingtariffs', 1.0, 'OMC Private Charging Tariffs Rest API',);
```
To model that the REST API interface is exposed at the Apim Gateway, you should use the "createNetworkEndpoint" method and mention the Rest API and Gateway as parameters. To use the Apim Gateway is necessary to import the component: "omcPublicApimGateway".

The endpoint concept is not the term associated with API endpoints, this must be found from the Open API specifications of the service, in this case, it is the endpoint where the API can be consumed (API Gateway or a Network Gateway).

```typescript
import {omcPublicApimGateway} from '../apiGateways/omcPublicApimGatewaySystem';
...
export const omcPrivateChargingTariffsEndpoint = omcChargingHistoryCompositeSystem.createNetworkEndpoint('OMC Private Charging Tariffs - Tariffs Endpoint',
omcPrivateChargingTariffsRestApi, omcPublicApimGateway, InterfaceType.REST);
```
This system contains a database in "Cosmos" that saves tariffs. Hence, at the system object level, the "createCosmosDatabase" method is invoked to create a database in Cosmos.

The database is only accessible within the system hence that it does not include the "export" attribute.

```typescript
const omcPrivateChargingTariffsCosmosDB = omcChargingHistoryCompositeSystem.createCosmosDatabase('OMC Private Charging Tariffs DB')
    .withDescriptiveName('Private Charging Tariffs - Tariff V2 DB')
    .withDescription('Store Private Charging Tariffs');
```
The tariff management service is the only component that connects to the tariff database, so the "uses" method of the object "omcPrivateChargingTarifftariffsService" is invoked to indicate this dependency.

```typescript
omcPrivateChargingTariffsService.uses(omcPrivateChargingTariffsCosmosDB, 'store / get private charging tariffs for a user / vehicle');
```
Once the core service components are created, the BFF service for tariffs is set. 

```typescript
const omcPrivateChargingTariffsCompositeService = omcChargingHistoryCompositeSystem.createMicroservice('mobile20-PCT')     
    .withDescriptiveName('Mobile20 - Private Charging Tariffs Composite')
    .withDescription('Provides an interface to manage private charging tariffs from core service to mobile App.')   
    .withDocumentationUrl('https://code.connected.bmw/emobility/private-charging-tariffs-composite-service');
 
// API
export const omcPrivateChargingTariffsCompositeRestApi = omcPrivateChargingTariffsCompositeService.createRestApi('bmw-omc-mobile20pct-privatechargingtariffscomposite',1.0, 'OMC Private Charging Tariffs Composite Rest API',);
     
// Dependencies
omcPrivateChargingTariffsCompositeService.uses(omcPrivateChargingTariffsEndpoint, 'Call Private ChargingTariffs API');
```
Since the creation process is very similar to the previous one refers only to the use of the name convention for BFF ("mobile20-PCT") and the invocation of the dependence of the core service invoking the method "uses" and by sending as a parameter the endpoint for the "tariffs" feature ("omcPrivateChargingTarifftariffsEndpoint").

The entire System definition can be found at the [following link](https://atc.bmwgroup.net/bitbucket/projects/CDARCH/repos/arch_as_code/browse/src/architecture/model/de/connectedAppAndConversationServices/omc/eMobility/omcChargingHistoryComposite.ts).

## Add System to Subproduct
You start creating the eMobility subproduct within the OMC product, so a new file ("omcEMobilityProduct") is created within the subproduct folder created in the previous step.

In the new file you start by importing the "SubProduct" component and its systems into this subProduct, in this example, the component "omcChargingHistoryCompositeSystem" is also imported.

Then, the SubProduct "omcEMobilityProduct" is created with the "export" attribute so that it can be referenced by other modules, and finally, the system is added to the SubProduct using the "addSystem" method.

```typescript
import {SubProduct} from '../../../../../architecture';
import {omcChargingHistoryCompositeSystem} from './omcChargingHistoryComposite';
 
export const omcEMobilityProduct = new SubProduct('OMC EMobility')
.withDescription('Placeholder description for OMC eMobility')
     
omcEMobilityProduct.addSystem(omcChargingHistoryCompositeSystem)
```

## Add Subproduct to Product
To connect between the product and the sub-product it is necessary to find the product file (e.g. "omcProduct.ts") that is usually located in the product folder.

In this example, to add the link between the product and the sub-product you start by importing the component of the "omcEMobilityProduct" sub-Product and then add the sub-product to the product using the "addChild" method by sending as a parameter the component of the "omcEMobilityProduct" sub-Product.

```typescript
import {omcEMobilityProduct} from './eMobility/omcEMobilityProduct';
...
omcProduct.addChild(omcEMobilityProduct)
```
Thus, the documentation process of a new system is completed in the Compass tool.

It is recommended to read the compass tool's official documentation for more information on how to test the changes made. 

## Connected App 2.0 to BFFs
To establish the connection between Connected App 2.0 and BFFs is necessary to change the "connectedappInternal.ts" file to establish the relationship between the "connectedApp2" object and the Network Endpoints of each BFF, typically the Apim Endpoint.

To reference the BFFs is necessary to import the system at the beginning of the file.

The following code establishes the relationship between Connected App 2.0 and the BFFs of the Charging History Composite System.

```typescript
import {omcChargingSessionsApimEndpoint,omcPrivateChargingTariffsCompositeApimEndpoint, omcChargingDataPrivacyCompositeApimEndpoint } from './omc/eMobility/omcChargingHistoryComposite';
 ...
connectedApp2.uses(omcChargingSessionsApimEndpoint, 'get statistics/get charging sessions list/get charging sessions detail');
connectedApp2.uses(omcPrivateChargingTariffsCompositeApimEndpoint, 'get/set private charging tariffs');
connectedApp2.uses(omcChargingDataPrivacyCompositeApimEndpoint, 'get/set charging data privacy settings');
```