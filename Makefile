# A lot of this is inspired off of: https://github.com/jessfraz/dotfiles

SHELL := bash

.PHONY: all
all: install

.PHONY: install
install: cleanup install-app-files install-shell-files install-config-files install-util-files ## Installs shells, addons, bin fonts git gpg pictures

.PHONY: install-shell-files
install-shell-files: bash zsh zsh-addons

.PHONY: install-app-files
install-app-files: bin usr

.PHONY: install-config-files
install-config-files:  config docker git gpg vscode misc

.PHONY: install-util-files
install-util-files: fonts pictures

.PHONY: remove
remove: remove-shell-files remove-app-files remove-config-files remove-util-files ## Remove the dotfile configs; **WARNING: files will be deleted**

.PHONY: remove-shell-files
remove-shell-files: bash-remove zsh-remove zsh-addons-remove

.PHONY: remove-app-files
remove-app-files: bin-remove usr-remove

.PHONY: remove-config-files
remove-config-files: config-remove docker-remove git-remove gpg-remove vscode-remove misc-remove

.PHONY: remove-util-files
remove-util-files: fonts-remove  pictures-remove

.PHONY: cleanup
cleanup: ## Remove legacy files not used by current configuration
	if [ -L "$(HOME)/.alias" ]; then \
		rm "$(HOME)/.alias"; \
	fi;
	if [ -L "$(HOME)/.exports" ]; then \
		rm "$(HOME)/.exports"; \
	fi;
	if [ -L "$(HOME)/.bash_exports" ]; then \
		rm "$(HOME)/.bash_exports"; \
	fi;
	if [ -L "$(HOME)/.bash_alias" ]; then \
		rm "$(HOME)/.bash_alias"; \
	fi;
# if [ -L "$(HOME)/.bash_profile" ]; then \
# 	rm "$(HOME)/.bash_profile"; \
# fi;
	if [ -L "$(HOME)/.zsh_alias" ]; then \
		rm "$(HOME)/.zsh_alias"; \
	fi;
	if [ -L "$(HOME)/.docker_alias" ]; then \
		rm "$(HOME)/.docker_alias"; \
	fi;

.PHONY: bash
bash:
	for file in $(shell find "$(CURDIR)/bash" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file "$(HOME)/$$f"; \
	done;

	ln -snf "$(CURDIR)/bash/.bash-profile" "$(HOME)/.profile";

.PHONY: bash-remove
bash-remove:
	for file in $(shell find "$(CURDIR)/bash" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -f "$(HOME)/$$f" ]; then \
			rm "$(HOME)/$$f"; \
		fi; \
	done;

	if [ -f "$(HOME)/.profile" ]; then \
		rm "$(HOME)/.profile"; \
	fi;

.PHONY: bin
bin: ## Installs the bin directory files.
	# add aliases for things in bin
	for file in $(shell find "$(CURDIR)/bin" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done;

.PHONY: bin-remove
bin-remove:
	# add aliases for things in bin
	for file in $(shell find "$(CURDIR)/bin" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -f /usr/local/bin/$$f; ]; then \
			rm /usr/local/bin/$$f; \
		fi; \
	done;

.PHONY: config
config: ## Installs the base config dotfiles.
	mkdir -p "$(HOME)/.config";
	mkdir -p "$(HOME)/.local/share";

#	add aliases for dotfiles
	for file in $(shell find "$(CURDIR)" -maxdepth 1 -type f -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name ".pytest_cache" -not -name ".DS_Store"); do \
		f=$$(basename $$file); \
		ln -sfn $$file "$(HOME)/$$f"; \
	done;

	ln -snf "$(CURDIR)/i3" "$(HOME)/.config/sway";

	if [ -f /usr/local/bin/pinentry ]; then \
		sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
	fi;

.PHONY: config-remove
config-remove:
	mkdir -p "$(HOME)/.config";
	mkdir -p "$(HOME)/.local/share";

#	add aliases for dotfiles
	for file in $(shell find "$(CURDIR)" -maxdepth 1 -type f -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name ".pytest_cache" -not -name ".DS_Store"); do \
		f=$$(basename $$file); \
		if [ -f "$(HOME)/$$f" ]; then \
			rm "$(HOME)/$$f"; \
		fi; \
	done;

	if [ -d "$(HOME)/.config/sway" ]; then \
		rm "$(HOME)/.config/sway"; \
	fi;

	# if [ -f /usr/local/bin/pinentry ]; then \
	# 	sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
	# fi;

.PHONY: docker
docker:
	if [ -f "$(CURDIR)/docker/.docker-alias" ]; then \
		ln -snf "$(CURDIR)/docker/.docker-alias" "$(HOME)/.docker-alias"; \
	fi;
	if [ -f "$(CURDIR)/docker/.docker-functions" ]; then \
		ln -snf "$(CURDIR)/docker/.docker-functions" "$(HOME)/.docker-functions"; \
	fi;

.PHONY: docker-remove
docker-remove:
	if [ -f "$(HOME)/.docker-alias" ]; then \
		rm "$(HOME)/.docker-alias"; \
	fi;
	if [ -f "$(HOME)/.docker-functions" ]; then \
		rm "$(HOME)/.docker-functions"; \
	fi;

.PHONY: etc
etc: ## Installs the etc directory files.
	sudo mkdir -p /etc/docker/seccomp
	for file in $(shell find "$(CURDIR)/etc" -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|"$(CURDIR)"||'); \
		sudo mkdir -p $$(dirname $$f); \
		sudo ln -f $$file $$f; \
	done;

	systemctl --user daemon-reload || true

	sudo systemctl daemon-reload
	sudo systemctl enable systemd-networkd systemd-resolved
	sudo systemctl start systemd-networkd systemd-resolved
	sudo ln -snf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
	LAPTOP_MODEL_NUMBER=$$(sudo dmidecode | grep "Product Name: XPS 13" | sed "s/Product Name: XPS 13 //" | xargs echo -n); \
	if [[ "$$LAPTOP_MODEL_NUMBER" == "9300" ]]; then \
		sudo ln -snf "$(CURDIR)/etc/X11/xorg.conf.d/dell-xps-display-9300" "$(LAPTOP_XORG_FILE)"; \
	else \
		sudo ln -snf "$(CURDIR)/etc/X11/xorg.conf.d/dell-xps-display" "$(LAPTOP_XORG_FILE)"; \
	fi;

.PHONY: fonts
fonts: ## Installs fonts and related items.
	ln -snf "$(CURDIR)/fonts" "$(HOME)/.local/share/fonts";

	if [ -f "$(CURDIR)/.config/fontconfig/fontconfig.conf" ]; then \
		mkdir -p "$(HOME)/.config/fontconfig"; \
		ln -snf "$(CURDIR)/.config/fontconfig/fontconfig.conf" "$(HOME)/.config/fontconfig/fontconfig.conf"; \
	fi;

	if [ -f /usr/local/bin/fc-cache ]; then \
		fc-cache -f -v || true; \
	fi;

.PHONY: fonts-remove
fonts-remove:
	if [ -d "$(HOME)/.local/share/fonts" ]; then \
		rm "$(HOME)/.local/share/fonts"; \
	fi;

	if [ -f "$(HOME)/.config/fontconfig/fontconfig.conf" ]; then \
		rm "$(HOME)/.config/fontconfig/fontconfig.conf"; \
	fi;

	if [ -f /usr/local/bin/fc-cache ]; then \
		fc-cache -f -v || true; \
	fi;

.PHONY: git
git: ## Installs Git config files
	for file in $(shell find "$(CURDIR)/git/config-profiles" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file "$(HOME)/.$$f"; \
	done;

	if [ -f "$(CURDIR)/git/gitignore" ]; then \
		ln -sfn "$(CURDIR)/git/gitignore" "$(HOME)/.gitignore"; \
	fi;
	if [ -f "$(CURDIR)/git/gitconfig" ]; then \
		ln -sfn "$(CURDIR)/git/gitconfig" "$(HOME)/.gitconfig"; \
	fi;

	## git update-index --skip-worktree "$(HOME)/.gitconfig";

.PHONY: git-remove
git-remove:
	for file in $(shell find "$(CURDIR)/git/config-profiles" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -f "$(HOME)/.$$f" ]; then \
			rm "$(HOME)/.$$f"; \
		fi; \
	done;

	if [ -f "$(HOME)/.gitignore" ]; then \
		rm "$(HOME)/.gitignore"; \
	fi;
	if [ -f "$(HOME)/.gitconfig" ]; then \
		rm "$(HOME)/.gitconfig"; \
	fi;

.PHONY: gpg
gpg: ## Installs GPG config files
	# gpg --list-keys || true;
	mkdir -p "$(HOME)/.gnupg"

	for file in $(shell find "$(CURDIR)/gnupg" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file "$(HOME)/.gnupg/$$f"; \
	done;

.PHONY: gpg-remove
gpg-remove:
	# gpg --list-keys || true;
	# mkdir -p "$(HOME)/.gnupg" # leave folder as other keys/items may be in use

	for file in $(shell find "$(CURDIR)/gnupg" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -f "$(HOME)/.gnupg/$$f" ]; then \
			rm "$(HOME)/.gnupg/$$f"; \
		fi; \
	done;

.PHONY: misc
misc:
	# Neofetch
	mkdir -p "$(HOME)/.config/neofetch"

	for file in $(shell find "$(CURDIR)/neofetch" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file "$(HOME)/.config/neofetch/$$f"; \
	done;

.PHONY: misc-remove
misc-remove:
	for file in $(shell find "$(CURDIR)/neofetch" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -f "$(HOME)/.config/neofetch/$$f" ]; then \
			rm "$(HOME)/.config/neofetch/$$f"; \
		fi; \
	done;


.PHONY: pictures
pictures: ## Installs picture and settings
	mkdir -p "$(HOME)/Pictures";
	# ln -snf "$(CURDIR)/central-park.jpg" "$(HOME)/Pictures/central-park.jpg";

.PHONY: pictures-remove
pictures-remove:
	# mkdir -p "$(HOME)/Pictures";
	if [ -f "$(HOME)/Pictures/central-park.jpg" ]; then \
		rm "$(HOME)/Pictures/central-park.jpg"; \
	fi;

.PHONY: usr
usr: ## Installs the usr directory files.
	for file in $(shell find "$(CURDIR)/usr" -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|"$(CURDIR)"||'); \
		sudo mkdir -p $$(dirname $$f); \
		sudo ln -f $$file $$f; \
	done;

.PHONY: usr-remove
usr-remove:
	for file in $(shell find "$(CURDIR)/usr" -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|"$(CURDIR)"||'); \
		rm $$(dirname $$f); \
		rm $$f; \
	done;

.PHONY: vscode
vscode: ## Installs VSCode related config files
	for file in $(shell find "$(CURDIR)/vscode" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -d "$(HOME)/Library/Application Support/Code/User" ]; then \
			ln -sfn $$file "$(HOME)/Library/Application Support/Code/User/$$f"; \
		fi; \
	done;

.PHONY: vscode-remove
vscode-remove:
	for file in $(shell find "$(CURDIR)/vscode" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -d "$(HOME)/Library/Application Support/Code/User" ]; then \
			if [ -f "$(HOME)/Library/Application Support/Code/User/$$f" ]; then \
				rm "$(HOME)/Library/Application Support/Code/User/$$f"; \
			fi; \
		fi; \
	done;

.PHONY: zsh
zsh:
	for file in $(shell find "$(CURDIR)/zsh" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file "$(HOME)/$$f"; \
	done;

.PHONY: zsh-remove
zsh-remove:
	for file in $(shell find "$(CURDIR)/zsh" -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		if [ -f "$(HOME)/$$f" ]; then \
			rm "$(HOME)/$$f"; \
		fi; \
	done;

.PHONY: zsh-addons
zsh-addons:
#	# echo ${ZSH}
#	# echo $(ZSH_CUSTOM)/dir
#	# echo ${HOME}/.oh-my-zsh/custom/dir
#	# echo $((ZSH_CUSTOM):-$(HOME)/.oh-my-zsh/custom)/dir
#	powerlevel10k power theme
#	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || (cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && git pull)
#	Setup autosuggestions
#	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ## || (cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git pull )

.PHONY: zsh-addons-remove
zsh-addons-remove:
#	xrdb -merge $(HOME)/.Xdefaults || true
#	xrdb -merge $(HOME)/.Xresources || true

# Get the laptop's model number so we can generate xorg specific files.
# LAPTOP_XORG_FILE=/etc/X11/xorg.conf.d/10-dell-xps-display.conf


.PHONY: test
test: shellcheck ## Runs all the tests on the files in the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
	INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
	ifeq ($(INTERACTIVE), 1)
		DOCKER_FLAGS += -t
	endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		jess/shellcheck ./test.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## hdhd