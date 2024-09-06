STOW_DIR = $(shell pwd)/config
STOW_COMMON = $(shell ls -df config/common_* 2>/dev/null | xargs basename -a)
STOW_OSX = $(shell ls -df config/osx_* 2>/dev/null | xargs basename -a) 
STOW_WSL = $(shell ls -df config/wsl_* 2>/dev/null | xargs basename -a)
STOW_LINUX = $(shell ls -df config/linux_* 2>/dev/null | xargs basename -a)
STOW = /home/linuxbrew/.linuxbrew/bin/stow

default: bootstrap

info: ## Info about the current environment
	@echo "STOW_DIR: $(STOW_DIR)"
	@echo "STOW_COMMON: $(STOW_COMMON)"
	@echo "STOW_OSX: $(STOW_OSX)"
	@echo "STOW_WSL: $(STOW_WSL)"
	@echo "STOW_LINUX: $(STOW_LINUX)"

install: ## install all stows
	@rm -f $$HOME/.bashrc
	@rm -f $$HOME/.bash_profile
	@rm -f $$HOME/.profile
	@if [ "$$WSL_DISTRO_NAME" != "" ]; then \
		${STOW} --dir $(STOW_DIR) --target ~ $(STOW_COMMON) $(STOW_WSL); \
	fi
	@if [ "$$(uname)" = "Darwin" ]; then \
		${STOW} --dir $(STOW_DIR) --target ~ $(STOW_COMMON) $(STOW_OSX); \
	fi
	@if [ "$$(uname)" = "Linux" && "$$WSL_DISTRO_NAME" == "" ]; then \
		${STOW} --dir $(STOW_DIR) --target ~ $(STOW_COMMON) $(STOW_LINUX); \
	fi

delete: ## delete all stows
	@if [ "$$WSL_DISTRO_NAME" != "" ]; then \
		${STOW} --dir $(STOW_DIR) --delete --target ~ $(STOW_COMMON) $(STOW_WSL); \
	fi
	@if [ "$$(uname)" = "Darwin" ]; then \
		${STOW} --dir $(STOW_DIR) --delete --target ~ $(STOW_COMMON) $(STOW_OSX); \
	fi
	@if [ "$$(uname)" = "Linux" && "$$WSL_DISTRO_NAME" == "" ]; then \
		${STOW} --dir $(STOW_DIR) --delete --target ~ $(STOW_COMMON) $(STOW_LINUX); \
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

