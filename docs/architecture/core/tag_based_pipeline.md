---
layout: default
title: Tag Based Pipeline
parent: Core
grand_parent: Architecture
nav_order: 22
---

# Trunk based development with git tag deployments

## Overview

### Summary

Standard pipeline for backend services. 

### How this works

Note that tf-cluster-apps configurations will have a placeholder docker-tag that each environment uses. For example: latest/staging/production. This is the standard environment configuration we suggest using.
DLY: latest<br>
DEV/INT: staging<br>
PRD: production<br>

When a PR is made the developer must bump the current version by updating the current-version file. For example 1.0.1. The developer is also responsible for updating the CHANGELOG.md file and document changes and reference jira issues.

Once the PR is merged to master this will trigger a build that will publish two docker images, 1.0.1 and latest. Then it will trigger the DLY environments to pull down the image with the docker tag from the tf-cluster-app configuration and deploy the new container. It will also create a staging/1.0.1 github tag and push it to origin. This tag will generate a build in jenkins under the tags tab. 

Once the code has been validated in the DLY environments then someone will manually run the staging/1.0.1 build in jenkins. This will pull down the docker image with 1.0.1 as the docker tag. It then will copy this image and tag it with the 'staging' docker tag. Then it publishes this tag and triggers the DEV/INT deployments. Once that is complete it generates the release notes from the diff of the CHANGELOG.md file and then creates the staging/1.0.1 release. Finally it creates a production/1.0.1 github tag. This tag will also generate a build in jenkins under the tags tab.

Once DEV/INT environments are validated, someone can manually run the production/1.0.1 build. This will pull down the docker image with 1.0.1 as the docker tag. It then will copy this image and tag it with the 'production' docker tag. Then it publishes this tag and triggers the PROD deployments. Once this is complete it generates the release notes from the CHANGELOG.md and creates the production/1.0.1 github release.

### Pros
* Trunk based development reduces large merges.
* Use git tags to trigger deployments to upper environments.
* Github tags and releases are automated within the pipeline
* We can rollback to a previous version by simply running that versions git tag jenkins build.
* Better vision to what is deployed where.
* Release notes provide changes from last release.

### Cons
* Manual deployments for staging and production (git tags cannot trigger builds a the moment).

## Setup

New services:

Make sure your tf-cluster-app configs have the following docker tags configured:

DLY: latest<br>
DEV/INT: staging<br>
PRD: production<br>

Old services migrating to this pipeline:

The new jenkinsfile needs to be merged to master and both staging/{version} and production/{version} tag builds needs to be ran before merging the tf-cluster-app docker-tag config changes.

## High level deployment flow

<div class="mermaid">
  graph LR;
    A[PR Build]-->B[Checks, Build, Test];
    C[Master Build]-->D[Deploy to DLY];
    E[Staging Tag Build]-->F[Deploy to DEV/INT];
    G[Production Tag Build]-->H[Deploy to PRD];
</div>

## Pipeline steps ran when a pull request is made

<div class="mermaid">
  graph LR;
    A[PR Build]-->B[Check Version Bump];
    B[Check Version Bump]-->C[Check Changelog has new version];
    C[Check Changelog has new version]-->D[Validate Changelog ticket reference];
    D[Validate Changelog ticket reference]-->E[Check Format];
    E[Check Format]-->F[Run lint];
    F[Run lint]-->G[Build];
    G[Build]-->H[Test];
</div>

## Pipeline steps ran on merge to the master branch

<div class="mermaid">
  graph LR;
    A[Master Branch Build]-->E[Check Format];
    E[Check Format]-->F[Run lint];
    F[Run lint]-->G[Build];
    G[Build]-->H[Test];
    H[Test]-->I["Publish docker images:{currentVersion} and image:latest"];
    I["Publish docker images:{currentVersion} and image:latest"]-->J[Deploy to dly environments];
    J[Deploy to dly environments]-->K["Create staging/{currentVersion} github tag"];
</div>

## Pipeline steps ran when staging/{version} github tag build is manually ran in jenkins

<div class="mermaid">
  graph LR;
    A[Staging tag build]-->B[Pull currentVersion docker image];
    B[Pull currentVersion docker image]-->C[Publish docker image:staging];
    C[Publish docker image:staging]-->D["Deploy to dev/int environments"];
    D["Deploy to dev/int environments"]-->E["Get release notes from changelog"];
    E["Get release notes from changelog"]-->F["Create staging/{currentVersion} github release"];
    F["Create staging/{currentVersion} github release"]-->G["Create production/{currentVersion} github tag"];
</div>

## Pipeline steps ran when production/{version} github tag build is manually ran in jenkins

<div class="mermaid">
  graph LR;
    A[Production tag build]-->B[Pull currentVersion docker image];
    B[Pull currentVersion docker image]-->C[Publish docker image:production];
    C[Publish docker image:production]-->D["Deploy to prod environments"];
    D["Deploy to prod environments"]-->E["Get release notes from changelog"];
    E["Get release notes from changelog"]-->F["Create production/{currentVersion} github release"];
</div>