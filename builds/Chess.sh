#!/bin/sh
echo -ne '\033c\033]0;Chess\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Chess.x86_64" "$@"
