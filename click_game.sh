#!/bin/bash

# =============================================================================
# GoPit Game Clicker
# =============================================================================
# Automates clicking on UI elements in the GoPit web game running in Dia browser.
# Handles window resizing by using edge-anchored and center-scaled positioning.
#
# PREREQUISITES:
#   - macOS (uses AppleScript)
#   - cliclick installed: brew install cliclick
#   - Game running in Dia browser at https://go-pit.vercel.app
#
# USAGE:
#   ./click_game.sh <element> [count]
#
# ELEMENTS:
#   Game:     pause, start, green_fire, orange_fire, auto, blue_ball
#   Menu:     resume, sound, quit
#   GameOver: shop, restart, close
#   LevelUp:  levelup_left, levelup_mid, levelup_right
#
# EXAMPLES:
#   ./click_game.sh pause           # Pause the game
#   ./click_game.sh green_fire 10   # Fire 10 times
#   ./click_game.sh levelup_mid     # Select middle upgrade
#
# See AGENTS.md for full documentation and recalibration instructions.
# =============================================================================

# Reference window size (when offsets were originally captured)
REF_WIN_WIDTH=865
REF_WIN_HEIGHT=999

# Get Dia browser window position and size
get_window_info() {
    osascript -e '
    tell application "System Events"
        tell process "Dia"
            set win to front window
            set winPos to position of win
            set winSize to size of win
            set winX to item 1 of winPos as integer
            set winY to item 2 of winPos as integer
            set winW to item 1 of winSize as integer
            set winH to item 2 of winSize as integer
            return (winX as text) & "," & (winY as text) & "," & (winW as text) & "," & (winH as text)
        end tell
    end tell
    ' 2>/dev/null
}

# Get element positioning info
# Format: "anchor,x_val,y_val" where anchor is:
#   center = offset from center (scaled)
#   right  = offset from right edge (fixed x, scaled y)
#   bottom = offset from bottom edge (scaled x, fixed y from bottom)
get_element_info() {
    local element=$1
    case $element in
        # Edge-anchored elements (fixed distance from edge)
        pause)       echo "right,120,137" ;;  # 120px from right, 137px from top

        # Center-scaled elements
        start)       echo "center,0,217" ;;
        green_fire)  echo "center,-48,455" ;;
        orange_fire) echo "center,174,433" ;;
        auto)        echo "center,-35,409" ;;
        blue_ball)   echo "center,-170,443" ;;
        resume)      echo "center,3,-8" ;;
        sound)       echo "center,3,29" ;;
        quit)        echo "center,3,63" ;;
        shop)        echo "center,-62,146" ;;
        restart)     echo "center,37,147" ;;
        close)       echo "center,0,215" ;;
        levelup_left)   echo "center,-150,57" ;;
        levelup_mid)    echo "center,-3,52" ;;
        levelup_right)  echo "center,146,55" ;;
        *)           echo "" ;;
    esac
}

click_element() {
    local element=$1
    local info_str=$(get_element_info $element)

    if [ -z "$info_str" ]; then
        echo "Unknown element: $element"
        echo "Available: pause, resume, sound, quit, shop, restart, close, blue_ball, green_fire, auto, orange_fire, start, levelup_left, levelup_mid, levelup_right"
        return 1
    fi

    local anchor=$(echo $info_str | cut -d',' -f1)
    local x_val=$(echo $info_str | cut -d',' -f2)
    local y_val=$(echo $info_str | cut -d',' -f3)

    local win_info=$(get_window_info)
    if [ -z "$win_info" ]; then
        echo "Error: Could not get Dia browser window info"
        return 1
    fi

    local win_x=$(echo $win_info | cut -d',' -f1)
    local win_y=$(echo $win_info | cut -d',' -f2)
    local win_w=$(echo $win_info | cut -d',' -f3)
    local win_h=$(echo $win_info | cut -d',' -f4)

    local click_x click_y

    case $anchor in
        right)
            # Fixed distance from right edge, fixed distance from top
            click_x=$((win_x + win_w - x_val))
            click_y=$((win_y + y_val))
            ;;
        bottom)
            # Scaled x from center, fixed distance from bottom
            local scale_x=$(echo "scale=4; $win_w / $REF_WIN_WIDTH" | bc)
            local scaled_x=$(echo "scale=0; $x_val * $scale_x / 1" | bc)
            click_x=$((win_x + win_w / 2 + scaled_x))
            click_y=$((win_y + win_h - y_val))
            ;;
        center|*)
            # Scale both from center
            local center_x=$((win_x + win_w / 2))
            local center_y=$((win_y + win_h / 2))
            local scale_x=$(echo "scale=4; $win_w / $REF_WIN_WIDTH" | bc)
            local scale_y=$(echo "scale=4; $win_h / $REF_WIN_HEIGHT" | bc)
            local scaled_x=$(echo "scale=0; $x_val * $scale_x / 1" | bc)
            local scaled_y=$(echo "scale=0; $y_val * $scale_y / 1" | bc)
            click_x=$((center_x + scaled_x))
            click_y=$((center_y + scaled_y))
            ;;
    esac

    echo "Clicking $element at ($click_x, $click_y) [$anchor anchor, window: ${win_w}x${win_h}]"
    cliclick c:$click_x,$click_y
}

# Main
if [ -z "$1" ]; then
    echo "GoPit Game Clicker"
    echo "Usage: $0 <element_name> [count]"
    echo ""
    echo "Elements:"
    echo "  Game:     pause, start, green_fire, orange_fire, auto, blue_ball"
    echo "  Menu:     resume, sound, quit"
    echo "  GameOver: shop, restart, close"
    echo "  LevelUp:  levelup_left, levelup_mid, levelup_right"
    exit 0
fi

element=$1
count=${2:-1}

for ((i=1; i<=count; i++)); do
    click_element "$element"
    [ $count -gt 1 ] && sleep 0.3
done
