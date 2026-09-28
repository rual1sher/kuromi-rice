#!/bin/bash
# Install Kuromi rice by symlinking this repo into ~/.config and ~/.local/bin.
# Safe to re-run: existing files are backed up once, existing links are replaced.
set -e

REPO=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%s)

link() {
  local src="$REPO/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst && ! -L $dst ]]; then
    mv "$dst" "$dst.bak.$STAMP"
    echo "backup: $dst.bak.$STAMP"
  fi
  ln -sfn "$src" "$dst"
  echo "link:   $dst"
}

omarchy pkg add cava tty-clock playerctl fastfetch foot jq

link bin/kuromi-rice ~/.local/bin/kuromi-rice
link bin/kuromi-nowplaying ~/.local/bin/kuromi-nowplaying
link bin/kuromi-update ~/.local/bin/kuromi-update
link fastfetch/kuromi.jsonc ~/.config/fastfetch/kuromi.jsonc
link fastfetch/kuromi.ans ~/.config/fastfetch/kuromi.ans
link cava/config ~/.config/cava/config
link hypr/kuromi.lua ~/.config/hypr/kuromi.lua
link omarchy/themes/kuromi ~/.config/omarchy/themes/kuromi
link omarchy/plugins/rualisher.powermenu ~/.config/omarchy/plugins/rualisher.powermenu

# Load hypr/kuromi.lua after the user's own overrides.
if ! grep -q 'require("hypr.kuromi")' ~/.config/hypr/hyprland.lua; then
  printf '\n-- Kuromi rice (~/Projects/kuromi-rice).\nrequire("hypr.kuromi")\n' >>~/.config/hypr/hyprland.lua
  echo "hypr:   added require(\"hypr.kuromi\")"
fi

# Register the power menu plugin in the shell.
SHELL_JSON=~/.config/omarchy/shell.json
if [[ -f $SHELL_JSON ]] && ! jq -e '.plugins[]? | select(.id == "rualisher.powermenu")' "$SHELL_JSON" >/dev/null; then
  jq '.plugins = ((.plugins // []) + [{"id": "rualisher.powermenu"}])' "$SHELL_JSON" >"$SHELL_JSON.tmp"
  mv "$SHELL_JSON.tmp" "$SHELL_JSON"
  echo "shell:  added rualisher.powermenu plugin"
fi

hyprctl reload >/dev/null
omarchy theme set Kuromi
echo "done ✓"
