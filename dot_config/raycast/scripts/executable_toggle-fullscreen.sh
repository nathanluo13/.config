#!/bin/bash

# Toggle native macOS fullscreen (the green-button / Spaces fullscreen) on the
# frontmost window. Built for triggering from a Raycast hotkey while inside
# Windows App or Moonlight, so you can go fullscreen without swiping or hunting
# for the green button. Integrates with ~/.config/aerospace/fullscreen-watch.sh,
# which detects the resulting native-fullscreen state and suppresses AeroSpace
# keybindings while it is active.

# @raycast.schemaVersion 1
# @raycast.title Toggle Fullscreen
# @raycast.mode silent
# @raycast.icon 🖥️
# @raycast.packageName Window
# @raycast.description Toggle native macOS fullscreen on the frontmost window.

osascript <<'APPLESCRIPT'
tell application "System Events"
    set frontApp to first application process whose frontmost is true
    tell frontApp
        if (count of windows) is 0 then return
        set fsAttr to attribute "AXFullScreen" of window 1
        set isFS to value of fsAttr
        set value of fsAttr to (not isFS)
    end tell
end tell
APPLESCRIPT
