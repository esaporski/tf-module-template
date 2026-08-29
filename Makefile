MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.DEFAULT_GOAL := help
.PHONY: help

## Release:
bump: ## Bump semantic version based on the git log and generate changelog
	@echo "+ $@"
	@echo -e "\n+ Running cz bump..."
	@git config --local core.commentChar ";"
	@(current_version="$$(cz version --project)" \
		&& next_version="$$(cz bump --get-next --yes)" \
		&& if [ "$$current_version" != "0.0.1" ]; then changelog_start_rev="--start-rev $${current_version}"; fi \
		&& short_changelog="$$(eval cz changelog --dry-run --extra 'create_short_changelog=true' --unreleased-version "$$next_version" "$$changelog_start_rev")" \
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
