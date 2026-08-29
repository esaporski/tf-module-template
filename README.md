# TF Module Template

[![Copier](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/copier-org/copier/master/img/badge/badge-grayscale-inverted-border-teal.json)](https://github.com/copier-org/copier)
![GitHub Tag](https://img.shields.io/github/v/tag/esaporski/tf-module-template?color=blue)
[![License](https://img.shields.io/github/license/esaporski/tf-module-template.svg)](https://github.com/esaporski/tf-module-template/blob/master/LICENSE)

A [Copier template](https://github.com/copier-org/copier) that initializes a Terraform/OpenTofu module.

## Features

- Compatible with Terraform and OpenTofu
- [VSCode](https://code.visualstudio.com)/[VSCodium](https://vscodium.com) and [EditorConfig](https://editorconfig.org) integration
- Generate documentation with [terraform-docs](https://terraform-docs.io)
- Ensure quality and consistency of your Terraform/OpenTofu code with [tflint](ttps://github.com/terraform-linters/tflint)
- Update version constraints in your Terraform/OpenTofu configurations with [tfupdate](https://github.com/minamijoyo/tfupdate)
- Find vulnerabilities and misconfigurations with [checkov](https://www.checkov.io) and [trivy](https://trivy.dev)
- Use [commitizen](https://commitizen-tools.github.io) to help maintain consistent and meaningful commit messages while automating version management
- Manage and maintain your pre-commit hooks with [pre-commit](https://pre-commit.com)

## Development

### Prerequisites

> [!TIP]
> You should [install uv](https://docs.astral.sh/uv/getting-started/installation/) to be able to install the dependencies below.

- [copier](https://copier.readthedocs.io/en/stable/#installation)
- [commitizen](https://commitizen-tools.github.io/commitizen/#installation)
- [pre-commit](https://pre-commit.com/#install)

### Make

To check the available targets, run `make help` (or just `make`):

```shell
$ make help
# Usage:
#   make <target>
#
# Targets:
#   Release:
#     bump                Bump semantic version based on the git log and generate changelog
#     pre-commit          Configure pre-commit and run on all the files in the repo
#   Help:
#     help                Show this help
```

### [Pre-commit](https://pre-commit.com/)

`pre-commit` is a framework for managing and maintaining git hook scripts. Git hooks run on every commit to automatically point out issues in code, documentation and other configuration files.

Install the git hook scripts and run `pre-commit` against all the files with:

```shell
make pre-commit
```

### [Commitizen](https://commitizen-tools.github.io/commitizen/)

`commitizen` is a release management tool that helps teams maintain consistent and meaningful commit messages while automating version management.

What `commitizen` does:

- Write clear, structured commit messages
- Automatically manage version numbers using [semantic versioning](https://semver.org/)
- Generate and maintain changelogs
- Streamline the release process

Create a new commit:

```shell
# Add files for commit
$ git add changed_file

# Create new commit with commitizen
$ cz c
```

### Release

This project uses `commitizen` to automate the release process.

To release a new version tag, run:

```shell
make bump
```

The `bump` target automates the following steps:

- Run the `commitizen` bump command (`cz bump`):
  - Bump the semantic version based on the git log
  - Generate the project documentation with `terraform-docs` (check `pre_bump_hooks` in `.cz.toml`)
  - Update the `CHANGELOG.md` file with the version changes
  - Update the project version in the specified files (check `version_files` in `.cz.toml`)
  - Generate a new `chore(release)` commit, triggering the git hooks with `pre-commit`
- Run `git push` commands to push the release commit/tag

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

[MIT License](https://github.com/esaporski/tf-module-template/blob/master/LICENSE)
