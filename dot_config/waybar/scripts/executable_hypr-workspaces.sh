#!/usr/bin/env bash
# Aerospace-style workspace indicator for waybar (Omarchy). Managed by chezmoi.
#
# Emits one JSON object per Hyprland event:
#   text    -> the active workspace name (single top-left indicator, e.g. "3" or "Q")
#   tooltip -> every occupied workspace and the apps in it (the hover "dropdown")
#
# Driven off Hyprland's event socket (.socket2) so it updates instantly; falls
# back to 1s polling if the socket can't be found.
set -u

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "$XDG_RUNTIME_DIR/hypr/" 2>/dev/null | head -1)"
  export HYPRLAND_INSTANCE_SIGNATURE
fi
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

emit() {
  local active
  active="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.name // "?"')"
  hyprctl clients -j 2>/dev/null | jq -c --arg active "$active" '
    [ .[]
      | select((.workspace.name // "") != "")
      | select((.workspace.name | startswith("special")) | not)
      | { ws: .workspace.name, app: (.class // .title // "?") }
    ]
    | group_by(.ws)
    | sort_by(.[0].ws)
    | ( map(
          (.[0].ws) as $ws
          | (map(.app) | join(", ")) as $apps
          | (if $ws == $active then "→ " else "   " end) + $ws + "   " + $apps
        )
        | join("\n")
      ) as $tt
    | { text: $active,
        tooltip: (if ($tt | length) > 0 then $tt else "workspace " + $active + " (empty)" end),
        class: "workspaces" }
  '
}

emit
if [ -S "$SOCK" ]; then
  socat -u UNIX-CONNECT:"$SOCK" - 2>/dev/null | while read -r ev; do
    case "$ev" in
      workspace\>*|workspacev2\>*|focusedmon\>*|activewindow\>*|openwindow\>*|closewindow\>*|movewindow\>*|movewindowv2\>*|createworkspace\>*|destroyworkspace\>*|renameworkspace\>*)
        emit ;;
    esac
  done
else
  while sleep 1; do emit; done
fi
