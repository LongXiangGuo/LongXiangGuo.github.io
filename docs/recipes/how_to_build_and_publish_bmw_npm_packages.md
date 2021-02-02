---
layout: default
title: How To Build and Publish BMW NPM Packages updates
parent: Recipes
nav_order: 5
---

# Getting Started with BMW NPM Packages

1. NPM Packages are hosted in a private [BMW NPM Server](http://btcnpmregistry.centralus.cloudapp.azure.com/#/). Make sure you have access. The repositories are stored in Github under the [libray](https://code.connected.bmw/library) organization. Currently, there are two different repositories: [bmw-lit-npm](https://code.connected.bmw/library/bmw-lit-npm) and [bmw-npm](https://code.connected.bmw/library/bmw-npm).

2. After you can access the server, please set your NPM registry to the private server with the following command in your terminal: `npm set registry http://btcnpmregistry.centralus.cloudapp.azure.com` as this will point NPM to the private server first to look for packages and then to the public server afterwards.

## How To Add a New NPM Package

- We use [lerna](https://github.com/lerna/lerna) to manage our all the packages in [bmw-npm](https://code.connected.bmw/library/bmw-npm) and [bmw-lit-npm](https://code.connected.bmw/library/bmw-lit-npm). Please read up on [lerna](https://github.com/lerna/lerna) to better understand it if you are not familiar with it.

- Currently there is no generator for adding a new NPM package, so it is a manual process.

1. Open the project and copy/paste one of the packages folders (ex. agents-api) and rename it to what your package will be called.

2. In your new package directory, delete the `dist` & `node_modules` folders if they exist.

3. Open `package.json` and rename the `name` property and `description` to match your package. Then delete any `dependencies` you won't need and add any you will.

4. Open `README.md` and update accordingly.

5. Now you are ready to get started on implementing your package. Inside of `lib` you can keep existing files as you need and just edit them accordingly. However, please make sure your package has `mocks` and `models` as well as an `index.ts` file.

- Please make sure to export all desired models in your `index.ts` file explicitly and not from a barrel file or they will not be exposed publicly.

## How to Publish a New Version of NPM

- This project uses [Lerna](https://lerna.js.org/) to manage all the packages. Please read up on lerna if you are unfamiliar first. We handle versioning all packages at the same time to keep them in sync, so to see the current version, check out the [npm registry](http://btcnpmregistry.centralus.cloudapp.azure.com/#/) and make sure you have access as you will need it to publish. You can also refer to the `lerna.json` file as well.

1. Run `npm set registry http://btcnpmregistry.centralus.cloudapp.azure.com` (you may have already done this and if so you can skip this step)

2. Run `run npm adduser --registry` to configure a username and password

3. Make your changes on your feature branch

4. Run `npm run build` and make sure the project builds successfully

5. Create a PR for your feature branch and get approvals. DO NOT MERGE. Once you have approvals for the work you are doing, then you will want to publish locally first, then push those changes to your branch and merge all at once.

6. Run `npm run publish` and follow the CLI to indicate which type of version you are choosing (major, minor, patch, custom). Please follow [semantic versioning](https://semver.org/)

7. After your build publishes successfully, you will need to push another change to master, as publishing locally will modify the `package.json` files as well as the `lerna.json`. Go ahead and commit your changes, when running `git add .` you will be prompted by the CLI for type of change you are making. This will create a custom tag, which will eventually be used to automate publishing.
