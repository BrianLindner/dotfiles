#!/bin/bash

# Linux specific aliases, work on both MacOS and Linux.
pbcopy() {
	stdin=$(</dev/stdin);
	pbcopy="$(which pbcopy)";
	if [[ -n "$pbcopy" ]]; then
		echo "$stdin" | "$pbcopy"
	else
		echo "$stdin" | xclip -selection clipboard
	fi
}
pbpaste() {
	pbpaste="$(which pbpaste)";
	if [[ -n "$pbpaste" ]]; then
		"$pbpaste"
	else
		xclip -selection clipboard
	fi
}

function mkcd() {
  mkdir -p "$@" && cd "$_";
}
