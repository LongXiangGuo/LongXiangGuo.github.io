# mobile-docs

Welcome to the Mobile 2.0 documentation site, maintained by the core team. You can access the live documentation here: [Connected 2.0 Docs](https://pages.code.connected.bmw/mobile20/mobile-docs/)

## How to contribute

This site is built with [Jekyll](https://jekyllrb.com), a theme called [just-the-docs](https://github.com/pmarsceill/just-the-docs) and it is powered and hosted in [Github Enterprise Pages](https://pages.github.com).

In order to contribute to this page, you will need first to:

### Docker

* Install Docker following installation steps [here](https://docs.docker.com/docker-for-mac/install/).

After installation you'll be able to run:
```bash
docker-compose up
```

This will start the Jekyll site builder & server in a container and you'll be able to see your changes by visiting `http://0.0.0.0:4000` in your browser.


### Local Install

* Install Jekyll on your local machine (you can use [Homebrew](https://brew.sh) if working with a Mac)

  ```bash
  sudo gem install jekyll
  ```

  * You may also need to install [Bundler](https://bundler.io/):

    ```bash
    gem install bundler
    bundle install
    ```

* Clone this repository

  * Clone with SSH:

    ```bash
    git clone git@code.connected.bmw:mobile20/mobile-docs.git
    ```

  * Or clone with HTTPS:

    ```bash
    https://code.connected.bmw/mobile20/mobile-docs.git
    ```

This site runs in two configurations: a local configuration determined by **_config_local.yml**, and the production configuration contained in **_config.yml**. In order to run this site locally, just run the server using the local configuration:

```bash
jekyll serve --config _config_local.yml
```

## Expanding the documentation

The documentation is written in [Markdown](https://www.markdownguide.org). All the documents are under the `docs` folder, and follow a file structure/folder hierarchy that matches the navigation hierarchy reflected in the [site](https://pages.code.connected.bmw/mobile20/mobile-docs/).

Every document's file name should have a very meaningful name, since it will appear in the URL; for example, if you want to created a document called `analytics.md`, and will be hosted under `docs/architecture/core`, the final url will be:

```bash
https://pages.code.connected.bmw/mobile20/mobile-docs/docs/architecture/core/analytics/
```

Every markdown document will need to start with the theme's metadata, like this:

```markdown
---
layout: default
title: Analytics
parent: Core
grand_parent: Architecture
nav_order: 9
---
```

...where:

* **layout** indicates the type of document. It should ALWAYS be *default*
* **title** will be the text displayed in the browser's tab
* **parent** indicates the parent node in the navigation hierarchy
* **grand_parent** has a similar meaning to *parent*, but it is only used if this page is part of third-level navigation hierarchy
* **nav_order** indicates the position in the navigation list. Please try to respect the order established

## Visualizing your changes locally

Before opening a pull request to submit your changes, please make sure you first visualize your changes locally by running:

### Docker
```bash
docker-compose up
```

Starts the Jekyll server with `_config_local.yml` at `http://0.0.0.0:4000`.
You'll be able to visualize your changes [here](http://0.0.0.0:4000/docs/architecture).

### Locally

```bash
jekyll serve --config _config_local.yml
```

If you read the output, you will see that there's a local server running at `http://127.0.0.1:4000` where you can see your changes. Once you have confirmed that everything works locally as expected, submit your changes!

## Thank you for contributing!

Happy coding!

👨‍💻👩‍💻