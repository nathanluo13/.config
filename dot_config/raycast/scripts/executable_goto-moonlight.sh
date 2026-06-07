#!/bin/bash

# Jump to the fullscreen Moonlight Space. Activating the app makes macOS switch to
# the Space its fullscreen window is pinned to — no swipe needed. Bind a Raycast
# hotkey to this.

# @raycast.schemaVersion 1
# @raycast.title Go to Moonlight
# @raycast.mode silent
# @raycast.icon 🌙
# @raycast.packageName Spaces
# @raycast.description Switch to the fullscreen Moonlight Space.

open -a "Moonlight"
