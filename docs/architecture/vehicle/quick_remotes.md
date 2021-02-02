---
layout: default
title: Quick Remotes
parent: Vehicle
nav_order: 4
grand_parent: Architecture
---

# Quick Remotes

## Overview

The Quick Remote feature allows a user to quickly send a command to their vehicle.

### User Flows

Describes the execution flow from the user perspective.

#### Common Flow (Lock, Horn-blow, Flash-lights)

![Quick Remote Lock]({{site.baseurl}}/assets/images/architecture/vehicle/quick_remotes/ux/quick_remote_lock.png)

#### Unlock Flow

![Quick Remote Unlock]({{site.baseurl}}/assets/images/architecture/vehicle/quick_remotes/ux/quick_remote_unlock.png)

#### Climatize Flow

![Quick Remote Climatize]({{site.baseurl}}/assets/images/architecture/vehicle/quick_remotes/ux/quick_remote_climate_now.png)

## State Flows

Describes flows and transition from the components point of view.

### Executing a Quick Remote

![Execute Quick Remote]({{site.baseurl}}/assets/images/architecture/vehicle/quick_remotes/quick_remote_components_flow/execute_quick_remote.png)

- (\*1) - Depending on the QuickRemoteBloc current state, this event is sent to QuickRemoteSyncBloc with a remoteServiceAction indicating a "start" or "stop" remote action. When state is running, remoteServiceAction sent is "stop", otherwise is "start".
- (\*2) - This animation depends on the yielded loading state. When it is "QuickRemoteExecutionInProgress", the animation is an idle icon with a loading indicator around it, and on "QuickRemoteStopInProgress", it is both a spinning icon and a loading indicator.
- (\*3) - On a QuickRemoteExecutionInProgressEvent, the yielded state also depends on the current state of QuickRemoteBloc. When state is running is yielded a QuickRemoteStopInProgress, otherwise QuickRemoteExecutionInProgress.
- (\*4) - This animation depends on the main state. When it is running the icon is spinning, otherwise is idle.
- (\*5) - The yielded main state is the same as it was before QuickRemoteExecutedEvent execution. The main state is either "running" or "idle".

### On Vehicle Update

![On Vehicle Update]({{site.baseurl}}/assets/images/architecture/vehicle/quick_remotes/quick_remote_components_flow/update_quick_remote.png)

On vehicle update, quickRemoteEnd timestamp is refreshed.

- (\*1) - On vehicle update, if there's running time remaining, the timer is updated, on updating the timer, if the state is NOT running, it changes to running and notifies this to QuickRemoteSyncBloc. Otherwise if the state is running and theres no time left a QuickRemoteSyncBloc is notified of this execution finishing.
