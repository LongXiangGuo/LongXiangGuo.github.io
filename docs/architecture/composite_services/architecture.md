---
layout: default
title: Architecture
parent: Composite Services
grand_parent: Architecture
nav_order: 2
---

# Composite Services Architecture

Most server-side JavaScript frameworks tend to not be opinionated and have little in terms of architecture. NestJS changes that by providing an opinionated project setup (inspired by Angular).

## Modules

Modules are the basic building blocks of every Nest application. Each application contains at least one module, the `AppModule`, which is our root module and should have imported into it the `InternalModule` (which should be auto-generated and not modified) and your modules for your feature. Modules group related features as `components`, `services`, and `controllers` together.

## Providers

Providers are a fundamental concept in Nest. Many of the basic Nest classes may be treated as a provider – services, repositories, factories, helpers, and so on. The main idea of a provider is that it can inject dependencies; this means objects can create various relationships with each other, and the function of "wiring up" instances of objects can largely be delegated to the Nest runtime system. A provider is simply a class annotated with an `@Injectable()` decorator. Typically we refer to Providers and Services interchangably.

## Services

Services are used to encapsulate business logic. The reasons for services is decoupling and to keep the controllers light. Services are just classes that are injected into the controller.

## Controllers

In NestJS, controllers are classes with lots of annotations that act as the interface for your microservice. Each method in the controller is decorated with an HTTP verb and path (specific to the function).

**e.g @Get, @Post, @Put, @Delete**

Our controllers also make use of lots of other annotations to allow auto-generated Swagger documentation.

## Pipes

A pipe is a class annotated with the `@Injectable()` decorator. Pipes should implement the PipeTransform interface. Pipes have two typical use cases:

- Transformation: transform input data to the desired output
- Validation: evaluate input data and if valid, simply pass it through unchanged; otherwise, throw an exception when the data is incorrect

Pipes operate on the `arguments` being processed by a `controller route handler`. Nest interposes a pipe just before a method is invoked, and the pipe receives the arguments destined for the method. Any transformation or validation operation takes palce at that time, after which the route handler is invoke with any (potentially) transformed agruments.

Pipes run inside the exceptions zone. This means when a Pipe throws an exception it is handled by the exceptions layer. Given that, it should be clear that when an exception is thrown in a Pipe, no controller method is subsequently executed.

## Utility Functions (utils)

These should be pure functions that have no external dependencies. Each of these functions should do only one thing and be extremely easy to unit test. The goal of having these utility functions is to allow your service to call them and keep the service logic simplified and easy to unit test.

## Folder Structure

Using the [generator-nestjs](https://code.connected.bmw/runtime/generator-nestjs) from Runtime will scaffold the project for you and create the folder structure. Seeing the existing folder structure should give you an idea on how to continue along the same path. Some quick notes:

- Have features grouped by folder under the v\* folder (i.e. v1/destinations/)
- Have your file names end with `**.service.ts, **.controller.ts, **.module.ts, **.utils.ts, **.model.ts, etc`
- Use barrel files, `index.ts` in each folder to collectively export all your common files. (ex. for `utils` folder, have a `index.ts` file that `export * from` for each util). This will allow you to collectively import using `{}` when you need them in other files
- Group unit test files with their implementation and postfix them with `**.spec.ts`.

## Dependency Injection

Dependency Injection is a significant design pattern. It decouples the usage of an object from its creation and makes a class independent of its dependencies. Generally speaking we delegate the creation of dependencies to someone else. In our case Nest. Nest comes with its own dependency injection. Again it resembles Angulars dependency injection.

Use dependency injection to allow your code to remain modularized and clean. By separating code into modules, controllers, services, utils and creating strict types this allows your codebase to remain clean and scalable.
