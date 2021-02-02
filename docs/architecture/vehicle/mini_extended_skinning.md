---
layout: default
title: MINI Extended Skinning
parent: Vehicle
nav_order: 7
grand_parent: Architecture
---

# MINI Extended Skinning (MES)

{: .no_toc }
For the inital 7/20 release, the MINI app will showcase a unique design in certain parts of the "Vehicle Tab". For this release, the design differences apply only to the "Vehicle Area" and the "Joy Tab Bar". After 7/20, the entire app will be rebranded for a full MINI look and feel.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## Notice

The MINI build of mobile-connected uses the same data sources as the BMW build. The differences introduced in the MES are merely cosmetic. Also, due to business requirements, the current architectural approach to this implementation duplicates a good amount of code and spreads the brand decision around the code. This will be refactored after 7/20.

## UI Proposal

The proposal for the MINI UI can be found [here]({{site.baseurl}}/assets/docs/architecture/vehicle/mini_ui_proposal.pdf)

## Vehicle Area/Status

![MINI Vehicle Area]({{site.baseurl}}/assets/images/architecture/vehicle/mini_vehicle_area.png)

### UX

For the MINI Vehicle Area all the flows and logic are the same as the BMW counterpart, only the visual presentation changes by shuffling elements around and changing colors and other minor details.
For example the ALL GOOD widget is presented with a different font and color (all this comes from themes) but shares the same functionality with the BMW one. The same is also true for the Issues List, shared functionality with a different coat of paint.
The major addition was the Check Status button, that is only present on the MINI side and mirrors the ALL GOOD widget tap function.
Also the MINI Vehicle Area ditches the gradient background color for a solid one.
The other major difference in layout is the overlaying of the vehicle image on top of the Fuel Indicator widget. Although the two circles aren't part of the Fuel Indicator widget, they house the progress indicator part of it. The Fuel Indicator is detailed on the next section.

### Overview

The current code can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/vehicle_tab/vehicle_area/vehicle_area_mini_widget.dart)
And [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_status/widgets/vehicle_status_mini.dart)

## Fuel Indicator

### UX

For the MINI Fuel Indicator the major difference from the BMW equivalent is visual.
MINI has a different way in displaying information, opting for a column rather than a row, so you start by the info label on top, then the level and lastly the range. For the range an extra icon was added.
For the progress indicators, MINI uses a rounded one to be more inline with the physical display inside the vehicle.

### Overview

The current code can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_status/widgets/fuel_indicator/fuel_indicator_mini_widget.dart)

## Tab Bar

![MINI Bottom Tab Bar]({{site.baseurl}}/assets/images/architecture/vehicle/joy_tab_bar_mini.png)

### UX

For the MINI Tab Bar the primary differences are the ditching of the labels for the individual items for the selector, removing the one from the top. Also the color scheme changes to accent more the overall theme of MINI, favoring strong colors over a mute background.

### Overview

The current code can be found [here](https://code.connected.bmw/mobile20/joy-ui/blob/master/lib/src/widgets/joy_tab_bar_mini.dart)

## Future Improvements

After the 7/20 release the MINI app will progressively shift its layouts and visual vocabulary to a more unique and vibrant representation, inline with the vision of the brand.
The rest of the vehicle tab will also be revamped. One change will bring more views/angles of the vehicle to allow the user an heightened sense of attachment to the vehicle.
Another major change will be the introduction of customizable colors or themes by the user.
