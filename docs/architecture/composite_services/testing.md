---

layout: default
title: Testing
parent: Composite Services
grand_parent: Architecture
nav_order: 3

---

# Composite Services Testing

Good tests are crucial to the long term success of every application. They point out the defects and errors we made during development. They indicate that new features work and ensure that they still work after a refactoring. They are just essential for every software. There are different types of tests. Unit tests, integration tests and end to end tests. Nest provides us with a setup for all kind of tests.

## Unit Testing

Unit Testing is the art of testing functions. Unit tests are used to ensure that the smallest entities in your application do what they are supposed to do. Nest uses Jest as a testing framework. The cool thing about Jest is that it provides a test runner, assert functions and testing utilities for mocking and spying.

### Testing Utilities

To boost and facilitate the testing process nest provides a testing package.
This testing package allows us to create a `TestingModule`. This testing module is used during tests instead of the real module. By using the testing module, we can easily mock services. We can provide mocks instead of a real implementation.

## End to End Testing (E2E)

Unlike Unit tests, end to end tests do not only test one function. They examine the whole functionality of one API endpoint. Again, Nest has us covered. It provides a nice solution for end to end testing. Thereby it uses the same configuration as for unit testing in addition to a library called Supertest. Supertest is used to simulate HTTP requests.
