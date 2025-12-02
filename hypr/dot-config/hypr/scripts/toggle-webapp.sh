#!/bin/bash

# Generic webapp toggle script
# Usage: toggle-webapp.sh <url>
# Automatically derives the window class prefix from the URL

if [ $# -eq 0 ]; then
    echo "Usage: $0 <url>"
    echo "Example: $0 'https://chatgpt.com'"
    exit 1
fi

URL="$1"

# Extract domain from URL (remove protocol, path, and query parameters)
DOMAIN=$(echo "$URL" | sed -E 's|https?://||; s|/.*||; s|\?.*||')

# Create the class prefix to match (chrome-<domain>__)
CLASS_PREFIX="chrome-${DOMAIN}__"

# Check if a window with this class prefix exists
WEBAPP_WINDOW=$(hyprctl clients -j | jq -r ".[] | select(.class | startswith(\"$CLASS_PREFIX\")) | .address" | head -n1)

if [ -z "$WEBAPP_WINDOW" ]; then
    # No window exists for this webapp, create one
    uwsm app -- chromium --new-window --ozone-platform=wayland --app="$URL" &
else
    # Window exists, check if it's on the current workspace
    CURRENT_WORKSPACE=$(hyprctl activewindow -j | jq -r '.workspace.id')
    WEBAPP_WORKSPACE=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$WEBAPP_WINDOW\") | .workspace.id")

    if [ "$WEBAPP_WORKSPACE" == "$CURRENT_WORKSPACE" ]; then
        # Window is visible on current workspace
        # Check if it's the active window
        ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

        if [ "$ACTIVE_WINDOW" == "$WEBAPP_WINDOW" ]; then
            # It's the active window, minimize it to special workspace
            # Use a special workspace named after the domain
            SPECIAL_NAME=$(echo "$DOMAIN" | sed 's/\./_/g')
            hyprctl dispatch movetoworkspacesilent special:$SPECIAL_NAME,address:$WEBAPP_WINDOW
        else
            # It's not active, focus it
            hyprctl dispatch focuswindow address:$WEBAPP_WINDOW
        fi
    else
        # Window is on another workspace or minimized, bring it to current workspace and focus
        hyprctl dispatch movetoworkspacesilent $CURRENT_WORKSPACE,address:$WEBAPP_WINDOW
        hyprctl dispatch focuswindow address:$WEBAPP_WINDOW
    fi
fi
