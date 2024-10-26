# A lot of this is inspired off of: https://github.com/jessfraz/dotfiles

SHELL := bash

CONFIG_HOME := "${HOME}/.config"

.PHONY: all
all: install

debug:
	echo CONFIG_HOME is ${CONFIG_HOME}

.PHONY: install
install: cleanup install-app-files install-shell-files install-config-files install-util-files ## Installs shells, addons, bin fonts git gpg pictures

.PHONY: install-shell-files
install-shell-files: bash zsh zsh-addons alias_path

.PHONY: install-app-files
install-app-files: bin usr python

.PHONY: install-config-files
install-config-files: config docker git gpg misc neovim vscode

.PHONY: install-util-files
install-util-files: fonts pictures

.PHONY: remove
remove: cleanup remove-shell-files remove-app-files remove-config-files remove-util-files ## Remove the dotfile configs; **WARNING: files will be deleted :WARNING**

.PHONY: remove-shell-files
remove-shell-files: bash-remove zsh-remove zsh-addons-remove alias_path-remove

.PHONY: remove-app-files
remove-app-files: bin-remove usr-remove python-remove

.PHONY: remove-config-files
remove-config-files: config-remove docker-remove git-remove gpg-remove misc-remove neovim-remove vscode-remove

.PHONY: remove-util-files
remove-util-files: fonts-remove  pictures-remove

.PHONY: uninstall
uninstall: remove ## Alias for remove; Remove the dotfile configs; **WARNING: files will be deleted :WARNING**

.PHONY: check
check:
	ls

.PHONY: distcheck
distcheck: check

.PHONY: cleanup
cleanup: ## Remove legacy files not used by current configuration
	# cleanup
#	if [ -L "${HOME}/.alias" ]; then \
#		rm "${HOME}/.alias"; \
#	fi;
	if [ -L "${HOME}/.exports" ]; then \
		rm "${HOME}/.exports"; \
	fi;
	if [ -L "${HOME}/.bash-alias" ]; then \
		rm "${HOME}/.bash-alias"; \
	fi;
	if [ -L "${HOME}/.bash-exports" ]; then \
		rm "${HOME}/.bash-exports"; \
	fi;
	if [ -L "${HOME}/.bash-functions" ]; then \
		rm "${HOME}/.bash-functions"; \
	fi;
	if [ -L "${HOME}/.bash-profile" ]; then \
		rm "${HOME}/.bash-profile"; \
	fi;
	if [ -L "${HOME}/.zsh-alias" ]; then \
		rm "${HOME}/.zsh-alias"; \
	fi;
	if [ -L "${HOME}/.zsh-functions" ]; then \
		rm "${HOME}/.zsh-functions"; \
	fi;
	if [ -L "${HOME}/.docker-alias" ]; then \
		rm "${HOME}/.docker-alias"; \
	fi;
	if [ -L "${HOME}/.docker-functions" ]; then \
		rm "${HOME}/.docker-functions"; \
	fi;

	if [ -L "${HOME}/.gitconfig-personal" ]; then \
		rm "${HOME}/.gitconfig-personal"; \
	fi;
	if [ -L "${HOME}/gitconfig-personal-github" ]; then \
		rm "${HOME}/gitconfig-personal-github"; \
	fi;
	if [ -L "${HOME}/.gitconfig-professional" ]; then \
		rm "${HOME}/.gitconfig-professional"; \
	fi;

.PHONY: alias_path
alias_path:
	ln -snf "${CURDIR}/.alias" "${HOME}/.alias";
	ln -snf "${CURDIR}/.path" "${HOME}/.path";

	if [ -f "${CURDIR}/macos/.macos_alias" ]; then \
		ln -snf "${CURDIR}/macos/.macos_alias" "${HOME}/.macos_alias"; \
	fi;
	if [ -f "${CURDIR}/macos/.macos_path" ]; then \
		ln -snf "${CURDIR}/macos/.macos_path" "${HOME}/.macos_path"; \
	fi;
	if [ -f "${CURDIR}/macos/.macos_exports" ]; then \
		ln -snf "${CURDIR}/macos/.macos_exports" "${HOME}/.macos_exports"; \
	fi;

.PHONY: alias_path-remove
alias_path-remove:
	if [ -L "${HOME}/.alias" ]; then \
		rm "${HOME}/.alias"; \
	fi;
	if [ -L "${HOME}/.path" ]; then \
		rm "${HOME}/.path"; \
	fi;

	if [ -L "${HOME}/.macos_alias" ]; then \
		rm "${HOME}/.macos_alias"; \
	fi;
	if [ -L "${HOME}/.macos_path" ]; then \
		rm "${HOME}/.macos_path"; \
	fi;
	if [ -L "${HOME}/.macos_exports" ]; then \
		rm "${HOME}/.macos_exports"; \
	fi;

.PHONY: bash
bash:
	# bash
	find "${CURDIR}/bash" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/$$f"; \
	done;

	ln -snf "${CURDIR}/bash/.bash_profile" "${HOME}/.profile";

.PHONY: bash-remove
bash-remove:
	# bash-remove
	find "${CURDIR}/bash" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -L "${HOME}/$$f" ]; then \
			rm "${HOME}/$$f"; \
		fi; \
	done;

	if [ -L "${HOME}/.profile" ]; then \
		rm "${HOME}/.profile"; \
	fi;

.PHONY: bin
bin: ## Installs the bin directory files.
	# bin
	mkdir -p "${HOME}/bin"
	# add aliases for items in bin
	find "${CURDIR}/bin" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sf "$$file" "${HOME}/bin/$$f"; \
	done;

	find "${CURDIR}/usr/local/bin" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		sudo ln -sf "$$file" "/usr/local/bin/$$f"; \
	done;

.PHONY: bin-remove
bin-remove:
	# bin-remove
	# remove aliases for items in bin
	find "${CURDIR}/bin" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -L "/usr/local/bin/$$f"; ]; then \
			rm "/usr/local/bin/$$f"; \
		fi; \
	done;

.PHONY: config
config: ## Installs the base config dotfiles.
	# config
	mkdir -p "${CONFIG_HOME}";
	mkdir -p "${HOME}/.local/share";

#	add aliases for dotfiles
	find "${CURDIR}" -depth 1 -type f -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name ".pytest_cache" -not -name ".DS_Store" -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/$$f"; \
	done;

	ln -snf "${CURDIR}/i3" "${CONFIG_HOME}/sway";

	if [ -f /usr/local/bin/pinentry ]; then \
		sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
	fi;

.PHONY: config-remove
config-remove:
	# config-remove
	# mkdir -p "${CONFIG_HOME}";
	# mkdir -p "${HOME}/.local/share";

#	remove aliases for dotfiles
	find "${CURDIR}" -depth 1 -type f -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name ".pytest_cache" -not -name ".DS_Store" -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${HOME}/$$f" ]; then \
			rm "${HOME}/$$f"; \
		fi; \
	done;

	if [ -d "${CONFIG_HOME}/sway" ]; then \
		rm "${CONFIG_HOME}/sway"; \
	fi;

	# if [ -f /usr/local/bin/pinentry ]; then \
	# 	sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
	# fi;

.PHONY: docker
docker:
	# docker
	if [ -f "${CURDIR}/docker/.docker-alias" ]; then \
		ln -snf "${CURDIR}/docker/.docker-alias" "${HOME}/.docker-alias"; \
	fi;
	if [ -f "${CURDIR}/docker/.docker-functions" ]; then \
		ln -snf "${CURDIR}/docker/.docker-functions" "${HOME}/.docker-functions"; \
	fi;

.PHONY: docker-remove
docker-remove:
	# docker-remove
	if [ -f "${HOME}/.docker-alias" ]; then \
		rm "${HOME}/.docker-alias"; \
	fi;
	if [ -f "${HOME}/.docker-functions" ]; then \
		rm "${HOME}/.docker-functions"; \
	fi;

.PHONY: etc
etc: ## Installs the etc directory files.
	# etc
	sudo mkdir -p /etc/docker/seccomp
	find "${CURDIR}/etc" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(echo "$$file" | sed -e 's|"${CURDIR}"||'); \
		sudo mkdir -p $$(dirname "$$f"); \
		sudo ln -f "$$file" "$$f"; \
	done;

	systemctl --user daemon-reload || true

	sudo systemctl daemon-reload
	sudo systemctl enable systemd-networkd systemd-resolved
	sudo systemctl start systemd-networkd systemd-resolved
	sudo ln -snf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
	LAPTOP_MODEL_NUMBER=$$(sudo dmidecode | grep "Product Name: XPS 13" | sed "s/Product Name: XPS 13 //" | xargs echo -n); \
	if [[ "$$LAPTOP_MODEL_NUMBER" == "9300" ]]; then \
		sudo ln -snf "${CURDIR}/etc/X11/xorg.conf.d/dell-xps-display-9300" "$(LAPTOP_XORG_FILE)"; \
	else \
		sudo ln -snf "${CURDIR}/etc/X11/xorg.conf.d/dell-xps-display" "$(LAPTOP_XORG_FILE)"; \
	fi;

.PHONY: fonts
fonts: ## Installs fonts and related items.
	# fonts
	ln -snf "${CURDIR}/fonts/fonts" "${HOME}/.local/share/fonts";
	ln -snf "${CURDIR}/fonts/fonts" "${HOME}/.fonts";

	if [ -f "${CURDIR}/fonts/fontconfig.conf" ]; then \
		mkdir -p "${CONFIG_HOME}/fontconfig"; \
		ln -snf "${CURDIR}/fonts/fontconfig.conf" "${CONFIG_HOME}/fontconfig/fontconfig.conf"; \
	fi;

	if [ -f /usr/local/bin/fc-cache ]; then \
		fc-cache -f -v || true; \
	fi;

.PHONY: fonts-remove
fonts-remove:
	# fonts-remove
	if [ -d "${HOME}/.local/share/fonts" ]; then \
		rm "${HOME}/.local/share/fonts"; \
	fi;

	if [ -d "${HOME}/.fonts" ]; then \
		rm "${HOME}/.fonts"; \
	fi;

	if [ -f "${CONFIG_HOME}/fontconfig/fontconfig.conf" ]; then \
		rm "${CONFIG_HOME}/fontconfig/fontconfig.conf"; \
	fi;

	if [ -f /usr/local/bin/fc-cache ]; then \
		fc-cache -f -v || true; \
	fi;

.PHONY: git
git: ## Installs Git config files
	# git
	find "${CURDIR}/git/config_profiles" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/.$$f"; \
	done;

	if [ -f "${CURDIR}/git/gitignore" ]; then \
		ln -sfn "${CURDIR}/git/gitignore" "${HOME}/.gitignore"; \
	fi;
	if [ -f "${CURDIR}/git/gitconfig" ]; then \
		ln -sfn "${CURDIR}/git/gitconfig" "${HOME}/.gitconfig"; \
	fi;

	## git update-index --skip-worktree "${HOME}/.gitconfig";

.PHONY: git-remove
git-remove:
	# git-remove
	find "${CURDIR}/git/config_profiles" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${HOME}/.$$f" ]; then \
			rm "${HOME}/.$$f"; \
		fi; \
	done;

	if [ -f "${HOME}/.gitignore" ]; then \
		rm "${HOME}/.gitignore"; \
	fi;
	if [ -f "${HOME}/.gitconfig" ]; then \
		rm "${HOME}/.gitconfig"; \
	fi;

.PHONY: gpg
gpg: ## Installs GPG config files
	# gpg
	# gpg --list-keys || true;
	mkdir -p "${HOME}/.gnupg"
	chmod 700 "${HOME}/.gnupg"

	find "${CURDIR}/gnupg" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/.gnupg/$$f"; \
	done;

.PHONY: gpg-remove
gpg-remove:
	# gpg-remove
	# gpg --list-keys || true;
	# mkdir -p "${HOME}/.gnupg" # leave folder as other keys/items may be in use

	find "${CURDIR}/gnupg" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${HOME}/.gnupg/$$f" ]; then \
			rm "${HOME}/.gnupg/$$f"; \
		fi; \
	done;

.PHONY: misc
misc:
	# misc
	# Neofetch
	mkdir -p "${CONFIG_HOME}/neofetch"

	find "${CURDIR}/neofetch" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${CONFIG_HOME}/neofetch/$$f"; \
	done;

	# Tmux
	mkdir -p "${CONFIG_HOME}/tmux"

	find "${CURDIR}/tmux" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		# ln -sfn "$$file" "${CONFIG_HOME}/tmux/$$f"; \
		ln -sfn "$$file" "${HOME}/$$f"; \
	done;

.PHONY: misc-remove
misc-remove:
	# misc-remove
	find "${CURDIR}/neofetch" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${CONFIG_HOME}/neofetch/$$f" ]; then \
			rm "${CONFIG_HOME}/neofetch/$$f"; \
		fi; \
	done;

	find "${CURDIR}/tmux" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${CONFIG_HOME}/tmux/$$f" ]; then \
			rm "${CONFIG_HOME}/tmux/$$f"; \
			rm "${HOME}/$$f"; \
		fi; \
	done;

.PHONY: neovim
neovim: ## Installs NeoVim config files
	# neovim
	mkdir -p "${CONFIG_HOME}/nvim"

	find "${CURDIR}/nvim" -depth 1 -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${CONFIG_HOME}/nvim/$$f"; \
	done;

	find "${CURDIR}/nvim" -depth 1 -type d -print0 | while IFS= read -r -d '' dir; do \
		d=$$(basename "$$dir"); \
		ln -sfn "$$dir" "${CONFIG_HOME}/nvim/$$d"; \
	done;

.PHONY: neovim-remove
neovim-remove:
	# neovim-remove
	find "${CURDIR}/nvim" -depth 1 -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${CONFIG_HOME}/nvim/$$f" ]; then \
			rm "${CONFIG_HOME}/nvim/$$f"; \
		fi; \
	done;

	find "${CURDIR}/nvim" -depth 1 -type d -print0 | while IFS= read -r -d '' dir; do \
		d=$$(basename "$$dir"); \
		echo "${CONFIG_HOME}/nvim/$$d"; \
		if [ -d "${CONFIG_HOME}/nvim/$$d" ]; then \
			echo "rm $$d"; \
			rm "${CONFIG_HOME}/nvim/$$d"; \
		fi; \
	done;

.PHONY: pictures
pictures: ## Installs sample picture and settings
	# pictures
	mkdir -p "${HOME}/Pictures";

	find "${CURDIR}/pictures" -type f ! -name .DS_Store ! -name .gitkeep -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/Pictures/$$f"; \
	done;

	# ln -snf "${CURDIR}/central-park.jpg" "${HOME}/Pictures/central-park.jpg";

.PHONY: pictures-remove
pictures-remove:
	# pictures-remove
	# if [ -f "${HOME}/Pictures/central-park.jpg" ]; then \
	# 	rm "${HOME}/Pictures/central-park.jpg"; \
	# fi;

	find "${CURDIR}/pictures" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${HOME}/Pictures/$$f" ]; then \
			rm "${HOME}/Pictures/$$f"; \
		fi; \
	done;

.PHONY: python
python:
	# python
	find "${CURDIR}/python" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/$$f"; \
	done;

.PHONY: python-remove
python-remove:
	# python-remove
	find "${CURDIR}/python" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -f "${HOME}/$$f" ]; then \
			rm "${HOME}/$$f"; \
		fi; \
	done;

.PHONY: synology
synology: ## Link Synology files
	# synology
	for d in ~/.SynologyDrive/data/session/*/conf; do \
		if [ -f "$$d" ]; then \
			ln -sfn "${CURDIR}/synology/drive_default_blacklist.filter" "$$d/blacklist.filter"; \
		fi; \
	done;

	for d in ~/.SynologyDrive/SynologyDrive.app/Contents/Resources/conf; do \
		if [ -f "$$d" ]; then \
			ln -sfn "${CURDIR}/synology/drive_global_blacklist.filter" "$$d/blacklist.filter"; \
		fi; \
	done;

.PHONY: synology-remove
synology-remove:
	# synology-remove
	for f in ~/.SynologyDrive/SynologyDrive.app/Contents/Resources/conf/blacklist.filter; do \
		rm $$f; \
	done;

	for f in ~/.SynologyDrive/data/session/*/conf/blacklist.filter; do \
		rm $$f; \
	done;

.PHONY: usr
usr: ## Installs the usr directory files.
	# usr
	find "${CURDIR}/usr" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(echo "$$file" | sed -e 's|"${CURDIR}"||'); \
		sudo mkdir -p $$(dirname "$$f"); \
		sudo ln -f "$$file" "$$f"; \
	done;

.PHONY: usr-remove
usr-remove:
	# usr-remove
	find "${CURDIR}/usr" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(echo "$$file" | sed -e 's|"${CURDIR}"||'); \
		rm $$(dirname "$$f"); \
		rm $$f; \
	done;

.PHONY: vscode
vscode: ## Installs VSCode related config files
	# vscode
	find "${CURDIR}/vscode" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -d "${HOME}/Library/Application Support/Code/User" ]; then \
			ln -sfn "$$file" "${HOME}/Library/Application Support/Code/User/$$f"; \
		fi; \
	done;

.PHONY: vscode-remove
vscode-remove:
	# vscode-remove
	find "${CURDIR}/vscode" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		if [ -d "${HOME}/Library/Application Support/Code/User" ]; then \
			if [ -f "${HOME}/Library/Application Support/Code/User/$$f" ]; then \
				rm "${HOME}/Library/Application Support/Code/User/$$f"; \
			fi; \
		fi; \
	done;

.PHONY: zsh
zsh:
	# zsh
	find "${CURDIR}/zsh" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		ln -sfn "$$file" "${HOME}/$$f"; \
	done;

.PHONY: zsh-remove
zsh-remove:
	# zsh-remove
	find "${CURDIR}/zsh" -type f ! -name .DS_Store -print0 | while IFS= read -r -d '' file; do \
		f=$$(basename "$$file"); \
		echo "Processing file: ${HOME}/$$f"; \
		if [ -f "${HOME}/$$f" ]; then \
			rm "${HOME}/$$f"; \
		fi; \
	done;

.PHONY: zsh-addons
zsh-addons:
# # zsh-addons
#	# echo ${ZSH}
#	# echo $(ZSH_CUSTOM)/dir
#	# echo ${HOME}/.oh-my-zsh/custom/dir
#	# echo $((ZSH_CUSTOM):-${HOME}/.oh-my-zsh/custom)/dir
#	powerlevel10k power theme
#	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || (cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && git pull)
#	Setup autosuggestions
#	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ## || (cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git pull )

.PHONY: zsh-addons-remove
zsh-addons-remove:
#	xrdb -merge ${HOME}/.Xdefaults || true
#	xrdb -merge ${HOME}/.Xresources || true

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
	# shellcheck
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v ${CURDIR}:/usr/src:ro \
		--workdir /usr/src \
		jess/shellcheck ./test.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
