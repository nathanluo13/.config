#!/bin/bash

# Jump to the fullscreen Windows App Space. Activating the app makes macOS switch
# to the Space its fullscreen window is pinned to — no swipe needed. Bind a Raycast
# hotkey to this.

# @raycast.schemaVersion 1
# @raycast.title Go to Windows App
# @raycast.mode silent
# @raycast.icon 🪟
# @raycast.packageName Spaces
# @raycast.description Switch to the fullscreen Windows App Space.

open -a "Windows App"
