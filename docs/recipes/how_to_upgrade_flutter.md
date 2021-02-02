---
layout: default
title: How To Upgrade Flutter
parent: Recipes
nav_order: 10
---

# How To Upgrade Flutter

Everything starts with a story in the core backlog 😉

### First, apply the changes locally

There's no magic when it comes to upgrading Flutter. However, to minimize the impact, the first step that we always run is to assign one developer to upgrade on their computers locally. The Flutter team has put this [guide](https://flutter.dev/docs/development/tools/sdk/upgrading) on how to upgrade. Remember, only upgrade to `stable` versions over the `stable` channel.

To verify that the upgrade was successful:

- Run the app and make sure everything works (or `e2e` for faster feedback)
- Run all the tests and validate that everything still works
- Run the lint
- Run the formatter

If you encounter any issues, fix them if you can. Once everything gets resolved, then it is time to upgrade the `Docker` image.

### Upgrading the Docker container

The pipeline uses this [Docker image](https://code.connected.bmw/docker/bmw-flutter-android) in the pipeline.

Upgrading the Flutter version of this image is as simple as modifying [this line](https://code.connected.bmw/docker/bmw-flutter-android/blob/aa9bb740dabb20b828e6a0193d5df7dca318cf1e/Dockerfile#L6) to the proper version of Flutter that you want to use, bump the version of the Docker image in this [Jenkinsfile](https://code.connected.bmw/docker/bmw-flutter-android/blob/master/Jenkinsfile), update the CHANGELOG, open an PR, and wait for the image to be published.

### Applying the new Docker image to the pipeline

In the `Jenkinsfile` of your Flutter project, simply upgrade the version of the Docker container to the new version, and boom! 💥 you are now using the new Flutter version!

### Communicating the changes to the team

Once this PR is merged, send an email/make an announcement over Teams to all the developers involved, so they can upgrade locally to the new version of Flutter as well.