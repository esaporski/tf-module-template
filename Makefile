MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

# macOS does not use GNU xargs
XARGS_FLAGS := xargs -i
ifeq ($(shell uname -s),Darwin)
	XARGS_FLAGS := xargs -I {}
endif

.DEFAULT_GOAL := help
.PHONY: help

## Build:
docs: ## Generate documentation (requires terraform-docs)
	@echo "+ $@"
	@echo -e "\n+ Running terraform-docs..."
	@terraform-docs \
		--config="./.terraform-docs.yml" --recursive=true --recursive-include-main=true --recursive-path=modules . \
	&& terraform-docs \
		--config="./.terraform-docs.yml" --recursive=true --recursive-include-main=false --recursive-path=examples .

.SILENT: init
init: ## Init all modules in this repository (main module, modules, examples and tests)
	@echo "+ $@"
	@echo -e "\n+ Running terraform init recursively..."
	@directories="$$(find $(CURDIR)/{examples,modules,tests}/* \
		-maxdepth 0 \
		-type d; \
		echo $(CURDIR))" \
	&& echo "$$directories" | $(XARGS_FLAGS) sh -c "echo Running command from \'{}\'; terraform -chdir={} init"

## Clean:
clean: ## Remove '.terraform' directories and lock files recursively
	@echo "+ $@"
	@find $(CURDIR) -name .terraform -type d | $(XARGS_FLAGS) rm -rf {}
	@find $(CURDIR) -name .terraform.lock.hcl -type f -exec rm -rf {} \;

## Test:
checkov: ## Run checkov using the '.checkov-config.yaml' configuration file
	@echo "+ $@"
	@echo -e "\n+ Running checkov..."
	@checkov --config-file="$(CURDIR)/.checkov-config.yaml" --directory $(CURDIR)

fmt: ## Format Terraform files recursively
	@echo "+ $@"
	@echo -e "\n+ Running terraform fmt recursively..."
	@terraform fmt -recursive $(CURDIR)

test: ## Run terraform test
	@echo "+ $@"
	@echo -e "\n+ Running terraform test..."
	@terraform test

tflint: ## Run tflint using the '.tflint.hcl' configuration file
	@echo "+ $@"
	@echo -e "\n+ Running tflint recursively..."
	@tflint --recursive --config "$(CURDIR)/.tflint.hcl"

tfupdate: ## Run tfupdate
	@echo "+ $@"
	@echo -e "\n+ Running tfupdate recursively..."
	@tfupdate terraform --recursive $(CURDIR)

trivy: ## Run trivy using the '.trivy.yaml' configuration file
	@echo "+ $@"
	@echo -e "\n+ Running trivy config..."
	@trivy --config "$(CURDIR)/.trivy.yaml" config $(CURDIR)

.SILENT: validate
validate: ## Validate all modules in this repository (main module, modules, examples and tests)
	@echo "+ $@"
	@echo -e "\n+ Running terraform validate recursively..."
	@directories="$$(find $(CURDIR)/{examples,modules,tests}/* \
		-maxdepth 0 \
		-type d; \
		echo $(CURDIR))" \
	&& echo "$$directories" | $(XARGS_FLAGS) sh -c "echo Running command from \'{}\'; terraform -chdir={} validate"

## Release:
bump: ## Bump semantic version based on the git log and generate changelog
	@echo "+ $@"
	@echo -e "\n+ Running cz bump..."
	@git config --local core.commentChar ";"
	@(current_version="$$(cz version --project)" \
		&& next_version="$$(cz bump --get-next --yes)" \
		&& if [ "$$current_version" != "0.0.1" ]; then changelog_start_rev="--start-rev $${current_version}"; fi \
		&& short_changelog="$$(eval cz changelog --dry-run --extra create_short_changelog=true --unreleased-version "$$next_version" "$$changelog_start_rev")" \
		&& cz changelog --unreleased-version "$$next_version" \
		&& cz bump --annotated-tag-message "$$short_changelog" --yes \
		&& git push \
		&& git push origin tag "$$next_version") || (git config --local core.commentChar "auto" && exit 1)
	@git config --local core.commentChar "auto"

pre-commit: ## Configure pre-commit and run on all the files in the repo
	@echo "+ $@"
	@echo -e "\n+ Running pre-commit hooks..."
	@pre-commit install --install-hooks
	@pre-commit run --all-files

## Help:
help: ## Show this help
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
