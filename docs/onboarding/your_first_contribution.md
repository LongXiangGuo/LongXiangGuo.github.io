---
layout: default
title: Your first contribution
parent: Onboarding
nav_order: 3
---

# Your first contribution

This guide assumes that you have already read [how to get started](/docs/onboarding/getting_started) and what's our [branching strategy](/docs/onboarding/how_to_use_git).

Now it is time to guide you through your first code contribution. At the end of this "mini" tutorial, you will:

- Clone the repository
- Create your feature branch
- Make some code changes
- Open a pull request
- See the pipeline running
- Have your first contribution added to production

## Cloning the repository

You can find the code hosted [here](https://code.connected.bmw/mobile20/mobile-connected). It is Github Enterprise, and our project is called `mobile-connected` under the `mobile20` organization.

In your terminal, go to your projects directory, and run the following command: `git clone git@code.connected.bmw:mobile20/mobile-connected.git`

After a few seconds, you should have a new folder called `mobile-connected` with the latest changes on the `master` branch.

## Create your feature branch

Now that you have a local copy of the code, it is time to create a feature branch, where you can make modifications to the code in a safely manner. Even if you try, pushing directly to `master` is totally blocked.

In order to create a branch, run this command on your terminal: `git checkout -b feature/my_first_contribution`. It is a good practice to prefix your branches with `feature/`, `bugfix/`, `spike/`... to give other developers an idea of what's the purpose of the branch.

Now that you have created your own feature branch, it is time to make code changes.

## Make some code changes

This is the fun the part, and the part where you have to use your imagination a little bit. The goal is start by making some code changes, while ensuring that all our tests are still passing. What's the best way to do this? By adding more tests! Adding more tests to ensure a correct behavior in our code is never a bad idea, and that is what we are going to do.

But first of all, we need to make sure we have pulled all the dependencies of the project: run `flutter packages get` in the root of the project to download all the dependencies. If in VS Code some of the other modules are still marked as red, you can `cd module && flutter packages get`, where module is the name of the folder marked as red. Alternatively, you could run `dart ./scripts/cli/cli.dart getPackages`.

In order to add a new tests, just go to `test/unit_test`; here is were all our unit tests are hosted. You can pick and choose where to make the changes, but I recommend checking the `formatters` tests, since you add there more and more tests to ensure every works as expected.

For example, if we had a `distance_converter.dart` that formats kilometers into meters, you could add tests that ensure that:

- 1 kilometer is 1000 meters
- 2.5 kilometers is 2500 meters
- 0 kilometers is 0 meters

In order to consider your changes ready, run `flutter test` and make sure all the tests are passing. We recommend to run your tests with coverage:

```bash
# You can use homebrew to install lcov
# brew install lcov

./scripts/pipeline/generate_coverage.sh ./path/to/package
open ./path/to/package/coverage/index.html
```

It is a requirement in the pipeline that our code coverage is at 100%, or the build won't pass.

We also recommend to run the formatter and the analyzer before commiting your changes, since the pipeline will fail your build if there are any errors or warnings:

- Dart Formatter: `dartfmt . -w`
- Dart Analyzer: `dartanalyzer --fatal-infos --fatal-warnings .`

## Open a pull request

Once your code changes are ready, and all the tests are passing, it is time to push the changes in your branch to the repository. In order to do that, you need to first stage and commit your changes: in your terminal, run `git add .` and `git commit -m "Adding unit tests as first code contribution"`. Now that your changes are committed locally, you can push to the repository by running `git push origin feature/my_first_contribution`.

Now, go to [code.connected.bmw](https://code.connected.bmw), visit the project's page and you will see highlighted an option to open a pull request. You can find more detailed steps here: [About pull requests](https://help.github.com/articles/about-pull-requests/)

Make sure that you add your team members as reviewers, or otherwise you won't be able to merge these changes.

## See the pipeline running

Once a pull request has been created, our build process will kick off. Our build server can be found at [btcbuild.bmwgroup.com](https://btcbuild.bmwgroup.com/view/mobile20/job/mobile20-mobile-connected/). You will also hear this build server being called "the pipeline". It is our mechanism to determine that all the automated checks and tests that we can run on the project are actually working as expected. Our pipeline will:

- Run code analysis and check the formatting
- Run unit and widget tests
- Run integration tests
- Build the different artifacts needed

## Have your first contribution added to production

Once the pipeline passes all the checks, you will be able to merge your pull request, in case it has been approved by all the reviewers assigned to it.

A second pipeline will be trigger, this time making sure that our `master` branch is still passing after the changes have been introduced. Furthermore, it will run a few additional steps, like deploying the different artifacts (Android APKs, iOS IPAs...) to AppCenter or any other different stores.

### The README file

There's a lot of useful information in the [README](https://code.connected.bmw/mobile20/mobile-connected) file of the main project. Take a look, and get familiar with the content. There's a lot of CLI helpers that might help you during your day to day.

## Congratulations!

Now that you have added your first snippets of code to the project, you can say that you have contributed to the success of Connected 2.0! We are very thankful for that!

In the Mobile 2.0 Core Team, we are always looking for ways to improve our materials, and we could not do that without your help and feedback; if you have any questions, or suggestions, or you just want to grab coffee with us (☕️), please email us at [Mobile2.0@list.bmw.com](mailto:Mobile2.0@list.bmw.com) and we will be incredible happy to assist you!

### Happy Coding! 👩‍💻👨‍💻