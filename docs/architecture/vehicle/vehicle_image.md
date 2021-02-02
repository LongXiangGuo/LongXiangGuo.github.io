---
layout: default
title: Vehicle Image
parent: Vehicle
nav_order: 3
grand_parent: Architecture
---

# Vehicle Image

## Existing solution

**COSY** is the "official" BMW service for providing vehicle images. Given a *VIN* and certain parameters, such as the *angle* and/or the *size* expected of the image, it will return the image requested.

COSY is used, in way way or another, in all BMW websites and customer facing products.

### Problem with the existing solution

The COSY API is misleading when requesting an image of a certain size: if you request an image of size 1000x1000 pixels, COSY will actually return a 1000x1000 image, but that does not mean that the vehicle itself will be 1000x1000: COSY will maintain the aspect ratio of the vehicle, and a certain unknown maximum size of the vehicle, and then it will fill the remaining space with empty pixels until the 1000x1000 requirement is fulfilled.

An image example explains it better:

![cosy transparent image]({{site.baseurl}}/assets/images/cosy_vehicle.png)

In red, we can see the vehicle image, and in blue the empty pixels added by COSY to provide an image of the requested size. 

This has been, historically, a challenge for multiple clients, that had to implement a cropping algorithm to reduce that extra padding (blue space), so they could display the image properly within their constraints. Even more challenging, multiple images might introduce shadows at random places, breaking the cropping algorithm, only solved by introducing a "shadow" threshold, totally random, to try to fix as many images as possible.

Having each client implementing its own cropping algorithm introduces bugs, duplication of efforts, and increases the cost of the product.

## Proposal

The proposal is to create a new microservice just dedicated to vehicle images. This microservice will try to match COSY's API as much as it can, but with the difference that will manipulate an image in the cases where COSY does not return the expected result.

For example, if COSY has an API like `GET {cosy.url}/image/{vin}?angle=FRONTSIDE`, our microservice should support `GET {new_vehicle_image_service.url}/image/{vin}?angle=FRONTSIDE`, return the "same" vehicle image, but without any additional padding.

This microservice will not require Client authentication.

### Phase 1 (MVP): just cropping, no caching

The first phase of this project would be to make a request to COSY every time a request comes in to this vehicle image service. Then, with the image provided by COSY, the service would apply the cropping algorithm.

<div class="mermaid">
  sequenceDiagram;
    Client-->NewVehicleImageService: GET /vehicle/{vin}/image?params;
    activate NewVehicleImageService;
    NewVehicleImageService -> COSY: GET /vehicle/{vin}/image?params;
    activate COSY;
    COSY --> NewVehicleImageService: Return COSY image with random padding;
    deactivate COSY;
    NewVehicleImageService --> Client: Return Image Cropped;
    deactivate NewVehicleImageService;
</div>

This solution is enough to accomplish an MVP. However, it might not very efficient since it is heavy on the computation side: we run the same algorithm for the same "image" over and over again.

### Phase 2: introduce a caching layer for efficiency

In order to try to save computation power and provide faster results, the phase 2 of this project would introduce a caching layer. Once an image has been processed by our vehicle image service, we should be able to cache it and, if requested again, provide the cached image rather than making a new request to COSY and apply the cropping algorithm again.

#### If image is in cache

<div class="mermaid">
  sequenceDiagram;
    Client-->NewVehicleImageService: GET /vehicle/{vin}/image?params;
    activate NewVehicleImageService;
    NewVehicleImageService-->Cache: Does image exist in cache?;
    activate Cache;
    Cache-->NewVehicleImageService: YES! Returning cached image;
    deactivate Cache;
    NewVehicleImageService-->Client: Return Image Cropped cached previously;
    deactivate NewVehicleImageService;
</div>

#### If image is NOT in cache

<div class="mermaid">
  sequenceDiagram;
    Client-->NewVehicleImageService: GET /vehicle/{vin}/image?params;
    activate NewVehicleImageService;
    NewVehicleImageService-->Cache: Does image exist in cache?;
    activate Cache;
    Cache-->NewVehicleImageService: NO! No result return;
    deactivate Cache;
    NewVehicleImageService-->COSY: GET /vehicle/{vin}/image?params;
    activate COSY;
    COSY-->NewVehicleImageService: Return COSY image with random padding;
    deactivate COSY;
    NewVehicleImageService-->Cache: save image in cache;
    NewVehicleImageService-->Client: Return Image Cropped;
    deactivate NewVehicleImageService;
</div>

### Technology Choices

* Node: given the UI nature of this project, we believe using JS technologies is the best choice for this project.
* NoSQL: given the unstructured nature of the information that needs to be saved, we believe NoSQL is the best approach.
* BlobStorage/S3: for storing the images