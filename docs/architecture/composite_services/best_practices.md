---

layout: default
title: Best Practices
parent: Composite Services
grand_parent: Architecture
nav_order: 5

---

# Best Practices

## Use NPM Packages for Core API's

Composite services should never directly make calls to each other. If you find yourself needing to access a core API, or an API that is used by multiple composite services, then abstract it out and create a separate NPM package for that. Look at the existing [bmw-npm](https://code.connected.bmw/library/bmw-npm) packages and follow that pattern. The use of these NPM packages is to allow composite services, or any other JS system to be able to use them, so please keep that in mind when generalizing them. Also, please make sure naming is appropriate for their use and not tied to something specific to a composite service.

## Reusable things belong in @bmw/nestjs

Since NestJS makes great use of pipes, and has a lot of convenient ones built-in, many times those will suffice. However, there are times where it makes sense to create a custom pipe to solve a problem. If that pipe can/will be reused in other composites, please create it in the existing NPM package @bmw/nestjs. This also applies to:

- guards
- interceptors
- models
- pipes
- utils

The above are just a few examples of things that have been reused amongst many composite services. There is no set rule for what goes in and what cannot, use your best judgement. However, always follow the guidelines of making the naming generic so it can be reused, and make sure there are applicable cases before putting it in the NPM package.
