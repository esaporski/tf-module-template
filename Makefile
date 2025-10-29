# macOS does not use GNU xargs
XARGS_FLAGS := xargs -i
ifeq ($(shell uname -s),Darwin)
	XARGS_FLAGS := xargs -I {}
endif

# Run 'make help' to see guidance on usage of this Makefile
# Note that comments with single '#' aren't rendered, requires '##'

.DEFAULT_GOAL := help
.PHONY: help
help:	## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bump: ## Bump semantic version based on the git log and generate changelog
	git config --local core.commentChar ";"
	(current_version="$$(cz version --project)" \
	&& next_version="$$(cz bump --get-next)" \
	&& short_changelog="$$(cz changelog --dry-run --extra create_short_changelog=true --unreleased-version "$$next_version" --start-rev "$$current_version")" \
	&& cz changelog --unreleased-version "$$next_version" \
	&& cz bump --annotated-tag-message "$$short_changelog" \
	&& git push \
	&& git push origin tag "$$next_version") || (git config --local core.commentChar "auto" && exit 1)
	git config --local core.commentChar "auto"

clean: ## Remove '.terraform' directories and lock files recursively
	@find $(CURDIR) -name .terraform -type d | $(XARGS_FLAGS) rm -rf {}
	@find $(CURDIR) -name .terraform.lock.hcl -type f -exec rm -rf {} \;

docs:	## Generate documentation (requires terraform-docs)
	terraform-docs \
		--config="./.terraform-docs.yml" --recursive=true --recursive-include-main=true --recursive-path=modules . \
	&& terraform-docs \
		--config="./.terraform-docs.yml" --recursive=true --recursive-include-main=false --recursive-path=examples .

fmt: ## Format Terraform files recursively
	terraform fmt -recursive $(CURDIR)

.SILENT: init
init: ## Init all modules in this repository (main module, modules, examples and tests)
	directories="$$(find $(CURDIR)/{examples,modules,tests}/* \
		-maxdepth 0 \
		-type d; \
		echo $(CURDIR))" \
	&& echo "$$directories" | $(XARGS_FLAGS) sh -c "echo Running command from \'{}\'; terraform -chdir={} init"

.SILENT: validate
validate: ## Validate all modules in this repository (main module, modules, examples and tests)
	directories="$$(find $(CURDIR)/{examples,modules,tests}/* \
		-maxdepth 0 \
		-type d; \
		echo $(CURDIR))" \
	&& echo "$$directories" | $(XARGS_FLAGS) sh -c "echo Running command from \'{}\'; terraform -chdir={} validate"

test: ## Run terraform test
	terraform test

checkov: ## Run checkov using the '.checkov-config.yaml' configuration file
	checkov --config-file="$(CURDIR)/.checkov-config.yaml" --directory $(CURDIR)

tflint: ## Run tflint using the '.tflint.hcl' configuration file
	tflint --recursive --config "$(CURDIR)/.tflint.hcl"

tfupdate: ## Run tfupdate
	tfupdate terraform --recursive $(CURDIR)

trivy: ## Run trivy using the '.trivy.yaml' configuration file
	trivy --config "$(CURDIR)/.trivy.yaml" config $(CURDIR)

pre-commit: ## Configure pre-commit and run on all the files in the repo
	pre-commit install --install-hooks
	pre-commit run --all-files
