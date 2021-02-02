---
layout: default
title: Data Privacy - Data Sharing is Off
parent: Vehicle
nav_order: 11
grand_parent: Architecture
---

# Data Privacy Off

{: .no_toc }
The widget warns the user when the data sharing is not available, what services are not updated and the procedure to enabled it.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## UX / UI

When Data Privacy is disabled, and according to the brand theme, a shadow vehicle and a banner with information about Data Privacy status with a link for a dialog with more information will be shown. The dialog explain why data is not being updated, what features this affect and how to fix this.

![BMW Vehicle Data Off]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_data_off.png)
![BMW Vehicle Data Off]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_data_off_dialog.png)

## Mobile Features Not Updated

- Vehicle Status
- Fuel Level or Charging Status 
- Remaining Range
- Vehicle Location

Remote features can still be executed, but status changes will not be transmitted.

## Procedure to enable Data Privacy

To enable all the mobile app features, data sharing needs to be turn on the active profile using the vehicle's in car display.
The steps to achive that is to select:

1 - Settings
![BMW Vehicle Settings]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_settings.png)

2 - General Settings
![BMW Vehicle General Settings]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_general_settings.png)

3 - Data Privacy
![BMW Vehicle Data Privacy]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_data_privacy.png)

Now you can choose a range of option to enable the features, as for example 'Individual Selection' or 'All Vehicle Services'
![BMW Vehicle Data Privacy Selection]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_data_privacy_selection.png)
![BMW Vehicle Data Privacy Features Selection]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_vehicle_data_privacy_features_selection.png)

