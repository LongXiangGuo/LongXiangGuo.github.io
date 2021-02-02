---
layout: default
title: How to create a Notification in Message Center
parent: Recipes
nav_order: 17
---

# How to create a Notification in Message Center
For a full overview of the architecture in place to create a Notification in Message center, refer to the architecture document for [Message Center Notifications]({{site.baseurl}}/docs/architecture/core/push_notifications/message_center_notifications).

The command needed to create a Notification in the notification service that will show in the Message center is below: 


```http
@NotificationServiceBaseUrl=https://btccndly-dev.chinaeast2.cloudapp.chinacloudapi.cn:51005/.gwy-public-proxy/svc/notification-service/
@Usid=your usid

POST {{NotificationServiceBaseUrl}}/v2/user/{{Usid}}/notifications
Content-Type: application/json

{
  "notificationTemplate": {
    "type": "basic",
    "buttonLayout": "vertical",
    "actionName": "button title1",
    "action": "https://flutter.dev?openType=openInBrowser?fullscreen=true",
    "actionName2": "button title2",
    "action2": "https://flutter.dev?openType=openInWebApp",
    "title": "detail page title",
    "subtitle": "detail page content with external link <a href=https://www.bmw.com.cn/zh/index.html >click here</a>",
    "disclaimer": "disclaimer link <a href=https://www.bmw.com.cn/zh/index.html >click here</a>",
    "image": "https://connetced.test.image1.png",
    "media": "https://bpic.588ku.com/ad_diversion/20/11/11/69d94db8cb289888815ca07f09295277.gif",
    "mediaType": "image",
    "mediaSize": "0.563",
    "dateTime": "2020-12-29T05:09:45.050Z",
    "createdOn": "2020-12-29T05:09:45.050Z",
    "expireOn": "2020-12-31T05:09:45.050Z",
  },
  "featureId": "localhost-test",
  "defaultLanguage": "zh-cn",
  "defaultVisibility": true,
  "lastModifiedDate": "2020-12-16T05:09:43.050Z"
}
```


***Important: When click the notification center list page item, it may deeplink to a subpage directly, so need add `fullscreen=true` to the action queryParameters if we want to show a fullscreen page, and this action will also act as the first button action.***

The `notificationTemplate` will mapping to a new payload with detailPage, below is the new payload and mapping code


## App recieved json

```js
{
      id: 'mock-notification-id',
      type: 'basic',
      fromNow: 'A few seconds ago',
      viewed: false,
      showed: false,
      action: 'bmw://connected/fullscreen',
      detailPage: {
        media: {
          asset: 'https://mock-host.com/images/bmw.png',
          type: 'image',
          aspectRatio: Number((9 / 16).toFixed(3)),
        },
        title: 'New Journey',
        content: 'Welcome to join us on an amazing journey',
        disclaimer: "disclaimer link <a href=\"https://www.bmw.com.cn/zh/index.html",
        image: 'https://mock-host.com/images/bmw.png',
        buttonLayout: 'vertical',
        actions: [
          {
            title: 'button title1',
            action: 'https://mock-host.com/actions/onboard.html?openType=openInBrowser',
          },
          {
            title: 'button title1',
            action: 'https://mock-host.com/actions/onboard.html?openType=openInWebApp',
          },
        ],
      },
    };
```

## App received json parameter definition

|key| value | type| description|
|---|---|---|---|
|media | contains asset/type/asspectRatio | dict  | the media contant for the detail notification page |
|aspectRatio|  Image:  1/1, 3/4, 9/16;  Video:  9/16 | double| the aspectRatio for asset, caculate with `height/width`|
|asset| can be joy icon name or url| string|the joy-ui icon name, image url or video url, desided by the type|
|title|title| string|title of the detail page |
|content|can be a plainText or `<a herf="your url"></a>`| string|content of the detail page |
|buttonLayout| vertical or horizontal| string|button direction, default is vertical|
|action| bmw://connected/fullscreen| string|deep link to the connected feature_module `_RootPage` and show fullscreen modal|
|action(actions)| {scheme}://{domain}/{mainTab}/{subpage-route}?openType={openType} | string| deeplink to other page, webApp or open the browser |
|image|image url| string|only for BMWOne, My BMW app is not use it|
 

## Deeplink action definition

|key| value|required| description|
|---|---|---|---| 
|scheme|bmw,mini,bundleId,https,customUrlScheme| true| decide which app to segue|
|domain|universalLinkDomain, connected, other external link domain| true| connected mean MyBmw App domain|
|subpage-route| subpage route name| true | which subpage to segue|
|mainTab|vehicle,destinations, profile,socialCn,serviceHubCn|true| change to the special mainTab, when is fullscreen, it's optional |
|title| title of the subPage | false | webview and fullscreen modal navigation bar title,default is empty |
|openType| openInWebApp,openInBrower| false| the open type of subpage, default is null|


## How Mapping to app received json sample code 

```js
 {
      id: notification.id,
      type: notification.type,
      action: NotificationUtils.getFirstAction(notification.action),
      fromNow: _.upperFirst(moment(notification.createdOn).fromNow()),
      viewed: !_.isEmpty(notification.readOn),
      showed: isReadNotification ? true : !_.isEmpty(notification.showedOn),
      detailPage: {
        media: {
          asset: notification.media,
          type: notification.mediaType,
          aspectRatio:
            notification.mediaSize?.split('.').length === 2
              ? Number(
                  (
                    Number(notification.mediaSize.split('.')[0]) 
                    Number(notification.mediaSize.split('.')[1])
                  ).toFixed(3),
                )
              : 0,
        },
        title: notification.title,
        content: notification.subtitle,
        disclaimer: notification.disclaimer,
        image: notification.image,
        buttonLayout: notification.buttonLayout,
        actions: [
          {
            title: notification.actionName,
            action: notification.action,
          },
          {
            title: notification.actionName2 ?? '',
            action: notification.action2 ?? '',
          },
        ],
      },
    };

  /**
   * determine the first action by query parameter 'fullscreen = true'.
   */
  private static getFirstAction(action: string): string {
    if (_.isEmpty(action)) {
      return FULL_SCREEN_ACTION;
    }

    const queryString = _.toLower(action).split('?')[1];
    const params = new URLSearchParams(queryString);
    if (_.toLower(params.get('fullscreen')) === 'true') {
      return FULL_SCREEN_ACTION;
    }
    return action;
  }
```

## Button deeplink sample code 

Below is the button click event in `NotificationDetailPage`, the `action` is came from backend, this function will route to webApp or browser if there exist a query string named `openType=openInBrowser` or `openType=openInWebApp`.

```dart
  Future _route(BuildContext context, String action) async {
    final queryParameters = Uri.tryParse(action ?? '').queryParameters;
    final openType = queryParameters['openType'];
    if (openType == 'openInBrowser') {
      await _NotificationBrowserUrlLauncher.openWebSite(
        action,
      );
    } else if (openType == 'openInWebApp') {
      Navigator.of(context).push(
        AppRoutes.fullscreenWebView(
          title: queryParameters['title'] ?? 'detail',
          url: action,
        ),
      );
    } else {
      _deeplinkAction = action;
      Navigator.of(context).pop();
    }
  }          
```

If you don't need to deeplink to external browser or webApp in `NotificationDetailPage`, instead, open a WebApp through the specified mainTab, you can register the route in the corresponding TabRoutes, and implement the route registration of WebView on specific page, e.g. :

- `bmw://connected/profile/financial_services?url=https%3a%2f%2ffs-mock-url.com%2fen-US`

```dart
class ProfileRoutes {

    ...
 case financialServicesRoute:
        String financialServicesUrl;
        if (settings.arguments is Map<String,String> ){
            financialServicesUrl = settings.arguments['url'];
        } else {
            financialServicesUrl = settings.arguments;
        }
        return MaterialPageRoute<FinancialServicesRoute>(
          builder: (context) =>
              FinancialServicesRoute(financialServicesUrl: financialServicesUrl),
        );
}

```