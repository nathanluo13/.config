#!/bin/bash

# Jump back to the "real Mac" — the AeroSpace-managed desktop Space. Focusing an
# AeroSpace window pulls macOS out of any fullscreen app Space and back to the
# tiled desktop, landing on whatever workspace was last focused (position
# preserved). Bind a Raycast hotkey to this.

# @raycast.schemaVersion 1
# @raycast.title Go to Mac Desktop
# @raycast.mode silent
# @raycast.icon 🖥️
# @raycast.packageName Spaces
# @raycast.description Switch back to the AeroSpace desktop Space.

AEROSPACE=/opt/homebrew/bin/aerospace
# Re-focus the currently-focused AeroSpace workspace; this returns macOS to the
# AeroSpace Space without changing which workspace you're on. Hardcode a number
# (e.g. `"$AEROSPACE" workspace 1`) instead if you'd rather always land on a home
# workspace.
"$AEROSPACE" workspace "$("$AEROSPACE" list-workspaces --focused)"
