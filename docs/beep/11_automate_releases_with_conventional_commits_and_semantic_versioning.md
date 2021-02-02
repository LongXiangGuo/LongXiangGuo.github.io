---
layout: default
title: "BEEP-11: Automate releases with conventional commits and semantic versioning"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 11
---

# BEEP-11: Automate releases with conventional commits and semantic versioning

### Authors

- Jorge Coca <jorge.coca@bmwna.com>

## Summary

Using the defined standards for [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) and [semantic versioning](https://semver.org) for our internal libraries, we can automate the release process and benefit from automation to generate extra information, such as descriptive CHANGELOGs and clear version control history.

## Motivation

Releasing a library manually is a tedious process, and many times, prone to "small" human mistakes: updating the CHANGELOG, selecting an incorrect tag... or just the fact that it is not going through a peer-review process are things that we should try to fix as part of our release process.

By using conventional commits, an bot integrated with Github Apps can determine what would be the right version upgrade that respects semantic versioning, 

### Detailed description

Once a project has been setup to use conventional commits, this is what you will have to do as a developer:

##### Start using conventional commits, either manually, with the CLI, or with the VS Code extension

- Manually **is not** a recommended option, but you have the spec here just in case: https://www.conventionalcommits.org/en/v1.0.0/#specification
- If you use the CLI from [Commitizen](https://commitizen.github.io/cz-cli/), it will look something like this: ![cli](https://github.com/commitizen/cz-cli/raw/master/meta/screenshots/add-commit.png)
- If you use the [VS Code extension](https://marketplace.visualstudio.com/items?itemName=KnisterPeter.vscode-commitizen), you will see a step-by-step helper similar to the CLI shown before.

###### The bot smenatic pull requests will lint the commits

This [bot](https://github.com/probot/semantic-pull-requests/) will be integrated in Github, adding an extra check that won't let developers merge a PR if the rules are not respected:

![bot](https://user-images.githubusercontent.com/2289/42729629-110812b6-8793-11e8-8c35-188b0952fd66.png)

##### lerna in the pipeline will take care of releasing the code 

By following this commit conversion, we can let `lerna` do the release with the `--conventional-commits` flag enabled, based on the commit history available since the last release.

```bash
$ lerna version --help

Bump version of packages changed since the last release.

Positionals:
  bump  Increment version(s) by explicit version _or_ semver keyword,
        'major', 'minor', 'patch', 'premajor', 'preminor', 'prepatch', or 'prerelease'.                       [string]

Command Options:
  --allow-branch             Specify which branches to allow versioning from.                                  [array]
  --amend                    Amend the existing commit, instead of generating a new one.                     [boolean]
  --conventional-commits     Use conventional-changelog to determine version bump and generate CHANGELOG.    [boolean]
  --conventional-graduate    Version currently prereleased packages to a non-prerelease version.
  --conventional-prerelease  Version changed packages as prereleases when using --conventional-commits.
  --changelog-preset         Custom conventional-changelog preset.                         [string] [default: angular]
  --exact                    Specify cross-dependency version numbers exactly rather than with a caret (^).  [boolean]
  --force-publish            Always include targeted packages in versioning operations, skipping default logic.
  --git-remote               Push git changes to the specified remote.                      [string] [default: origin]
  --create-release           Create an official GitHub or GitLab release for every version.
                                                                                [string] [choices: "gitlab", "github"]
  --ignore-changes           Ignore changes in files matched by glob(s) when detecting changed packages.
                             Pass --no-ignore-changes to completely disable.                                   [array]
  --ignore-scripts           Disable all lifecycle scripts                                                   [boolean]
  --include-merged-tags      Also include tags from merged branches                                          [boolean]
  -m, --message              Use a custom commit message when creating the version commit.                    [string]
  --no-changelog             Do not generate CHANGELOG.md files when using --conventional-commits.           [boolean]
  --no-commit-hooks          Do not run git commit hooks when committing version changes.                    [boolean]
  --no-git-tag-version       Do not commit or tag version changes.                                           [boolean]
  --no-push                  Do not push tagged commit to git remote.                                        [boolean]
  --preid                    Specify the prerelease identifier when versioning a prerelease  [string] [default: alpha]
  --sign-git-commit          Pass the `--gpg-sign` flag to `git commit`.                                     [boolean]
  --sign-git-tag             Pass the `--sign` flag to `git tag`.                                            [boolean]
  --tag-version-prefix       Customize the tag prefix. To remove entirely, pass an empty string. [string] [default: v]
  -y, --yes                  Skip all confirmation prompts.                                                  [boolean]

Global Options:
  --loglevel       What level of logs to report.                                              [string] [default: info]
  --concurrency    How many processes to use when lerna parallelizes tasks.                      [number] [default: 8]
  --reject-cycles  Fail if a cycle is detected among dependencies.                                           [boolean]
  --no-progress    Disable progress bars. (Always off in CI)                                                 [boolean]
  --no-sort        Do not sort packages topologically (dependencies before dependents).                      [boolean]
  --max-buffer     Set max-buffer (in bytes) for subcommand execution                                         [number]
  -h, --help       Show help                                                                                 [boolean]
  -v, --version    Show version number                                                                       [boolean]
```

Tools:

- [Semantic Pull Request](https://github.com/probot/semantic-pull-requests)
- [Commitizen CLI](http://commitizen.github.io/cz-cli/)
- [Commitizen for VS Code](https://github.com/KnisterPeter/vscode-commitizen)