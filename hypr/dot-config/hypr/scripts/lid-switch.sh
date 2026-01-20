#!/bin/bash

LAPTOP_MONITOR="desc:Chimei Innolux Corporation 0x1777"
LAPTOP_RESOLUTION="1920x1080@60.0,auto,1.0"

case "$1" in
    open)
        # Count external monitors (exclude the laptop monitor)
        external_count=$(hyprctl monitors -j | jq '[.[] | select(.description != "Chimei Innolux Corporation 0x1777")] | length')

        if [[ "$external_count" -eq 0 ]]; then
            hyprctl keyword monitor "$LAPTOP_MONITOR,$LAPTOP_RESOLUTION"
        fi
        ;;
    close)
        hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
        ;;
esac
