#!/bin/bash
# fullscreen-watch.sh
# Watches AeroSpace for a focused macOS native-fullscreen window and suppresses
# AeroSpace keybindings while one is active by switching into the (near-empty)
# 'fullscreen' mode. Returns to 'main' when the fullscreen app is left.
#
# Why a poller: AeroSpace has no fullscreen event hook. We keep AeroSpace ENABLED
# (rather than `enable off`) so its CLI keeps answering queries.
#
# Why timeouts: the AeroSpace 0.20.x-Beta CLI client occasionally wedges (a
# `list-windows` call can hang indefinitely connecting to the server). Without a
# timeout that single hung call freezes the whole loop, so the watcher silently
# stops reacting. Every AeroSpace call below is wrapped in aero() with a hard
# timeout; a wedged call is killed and simply retried on the next tick. macOS has
# no `timeout(1)`, so the timeout is implemented in pure bash.
#
# Managed by launchd: com.nathan.aerospace-fullscreen-watch

AEROSPACE="/opt/homebrew/bin/aerospace"
INTERVAL=1          # seconds between polls
TIMEOUT=3           # seconds before an AeroSpace call is considered wedged
TMP="/tmp/aerospace-fullscreen-watch.$$"
last=""             # last applied desired mode ("" forces a sync on first tick)

cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

# aero <args...> : run an aerospace command with a hard timeout.
# Prints stdout. Returns 0 on success, 1 on timeout/failure (and kills the hang).
aero() {
  "$AEROSPACE" "$@" >"$TMP" 2>/dev/null &
  local pid=$!
  local n=$(( TIMEOUT * 10 ))
  while [ "$n" -gt 0 ] && kill -0 "$pid" 2>/dev/null; do
    sleep 0.1
    n=$(( n - 1 ))
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    return 1
  fi
  wait "$pid" 2>/dev/null
  cat "$TMP"
  return 0
}

while true; do
  if ! layout="$(aero list-windows --focused --format '%{window-layout}')"; then
    # Call wedged or AeroSpace unavailable. Don't fight it; re-sync next time
    # AeroSpace answers cleanly.
    last=""
    sleep "$INTERVAL"
    continue
  fi

  if [ "$layout" = "macos_native_fullscreen" ]; then
    desired="fullscreen"
  else
    desired="main"
  fi

  if [ "$desired" != "$last" ]; then
    if aero mode "$desired" >/dev/null; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') ${last:-init} -> $desired (layout=$layout)"
      last="$desired"
    fi
  fi

  sleep "$INTERVAL"
done
