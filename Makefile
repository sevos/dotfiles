STOW_DIR = $(shell pwd)/config
STOW_COMMON = $(shell ls -d config/common_* | xargs basename -a)
STOW_OSX = $(shell ls -d config/osx_* | xargs basename -a) 
STOW_WSL = $(shell ls -d config/wsl_* | xargs basename -a)

default: bootstrap

info: ## Info about the current environment
	@echo "STOW_DIR: $(STOW_DIR)"
	@echo "STOW_COMMON: $(STOW_COMMON)"
	@echo "STOW_OSX: $(STOW_OSX)"
	@echo "STOW_WSL: $(STOW_WSL)"

install: ## install all stows
	@if [ "$$WSL_DISTRO_NAME" != "" ]; then \
		stow --dir $(STOW_DIR) --target ~ $(STOW_COMMON) $(STOW_WSL); \
	fi
	@if [ "$$(uname)" = "Darwin" ]; then \
		stow --dir $(STOW_DIR) --target ~ $(STOW_COMMON) $(STOW_OSX); \
	fi

delete: ## delete all stows
	@if [ "$$WSL_DISTRO_NAME" != "" ]; then \
		stow --dir $(STOW_DIR) --delete --target ~ $(STOW_COMMON) $(STOW_WSL); \
	fi
	@if [ "$$(uname)" = "Darwin" ]; then \
		stow --dir $(STOW_DIR) --delete --target ~ $(STOW_COMMON) $(STOW_OSX); \
	fi

bootstrap: bootstrap_stage1 install ## bootstrap the environment
	# Stage 2: Install all requirements
	@$$HOME/bin/system-bootstrap

bootstrap_stage1:
	# Stage 1: Install Homebrew and Stow
	@config/common_bootstrap/bin/system-bootstrap


update: ## update the sources
	./update_sources.sh

define print_help
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m%s\n", $$1, $$2}'
endef

help:
	@printf "\033[36mHelp: \033[0m\n"
	@$(foreach file, $(MAKEFILE_LIST), $(call print_help, $(file));)

