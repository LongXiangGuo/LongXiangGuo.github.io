---
layout: default
title: How To Setup A New Deep Link from a Push Notification
parent: Recipes
nav_order: 14
---

# How To Setup A New Deep Link from a Push Notification
1. **Make sure the push payload includes an action URI.**
    ````
    curl --location --request POST 'https://api.mobilitygraph.bmwgroup.com/agent/v1/motorist/{USID}/agents/{AGENT_ID}/pushnotification' \
    --header 'Ocp-Apim-Subscription-Key: {KEY}' \
    --header 'Content-Type: application/json' \
    --data-raw '{
      "Id": "{NOTIFICATION_ID}",
      "Badge": 0,
      "Silent": false,
      "Message": "Test push for deep linking",
      "Action": "bmw://connected/vehicle/customRouteName",
      "Type": "{NOTIFICATION_TYPE}",
      }                                                    
    ````
    All notification `type` options are defined here: [Agent Service -- Notification Types](https://code.connected.bmw/core-services/agent-service/blob/538ccdf766ce055db6dc1564996bee55dba430e5/AgentService/Models/PushNotificationType.cs)

> **Note:** See below for instructions on how to present a **fullscreen** modal as a detail page.

2. **Respond to the AppRouterBloc**
    - When the Push Notification is tapped, `push_notifications.dart` will recognize that `Action` is not null. At this point it will notify the AppRouterBloc that a deep link is being executed
    - The bloc will emit the state `SubPageRouterSuccess`
    - In the case that `Action` has been defined with `bmw://connected/vehicle/customRouteName` The state will contain the following properties:
      - `state.routeAction.mainTab == 'vehicle'` 
      - `state.routeAction.routeName == 'customRouteName'`
    - In `vehicle_tab_widget.dart` (or whatever respective Main Tab you are deeplinking into), ensure that there is a `BlocListener` responding to `AppRouterBloc`
      ````
      return BlocListener<AppRouterBloc, AppRouterState>(
        listener: (context, state) {
          if (state is SubPageRouterSuccess &&
              state.routeAction.mainTab == 'vehicle' &&
              state.routeAction.routeName == 'customRouteName') {
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(
              VehicleRoutes.onGenerateRoute(
                RouteSettings(
                  name: customRouteName,
                  arguments: {
                    'title': 'My Custom Route',
                    'description': 'Demo Route',
                  },
                ),
              ),
            );
          }
      ````
    - To add the custom route in, refer to the following files: 
      - `route_constants.dart`
      - `vehicle_app_routes.dart`
      - `vehicle_routes.dart`


## To Present a fullscreen modal 
- When an action is supplied with a value of `bmw://connected/fullscreen`, the app will route to the Notification Detail page. 
  - The Detail page will configure itself with the contents of the `detailPage` dictionary 
    - `title`: Prominent title of detail page (`String`)
    - `content`: Text blurb describing the notification (`String`)
    - `actions`: List of routes that can be taken from the notifcation [`Action`]
      - `Action`: 
        - `title`: Title of action, shown on the Detail Page button (`String`)
        - `action`: Deeplink route URL for the app to navigate to. (`String`)


````
{
	"type": "common",
	"id": "unique identifier",
	"action": "bmw://connected/fullscreen",
	"detailPage": {
		"title": "pickup success",
		"content": "pickup three hours, total 100$",
		"actions": [{
			"title": "detail",
			"action": "bmw://connected/{mainTab}/{subpage-route}?{queryKey}={queryValue}",
		}]
	}
}
````