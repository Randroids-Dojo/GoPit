#!/bin/bash

# =============================================================================
# GoPit Game Clicker
# =============================================================================
# Automates clicking on UI elements in the GoPit web game running in Dia browser.
# Calculates game canvas bounds based on 720x1280 aspect ratio, then positions
# elements relative to the canvas (not the window).
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

# Game canvas aspect ratio (from project.godot: 720x1280)
GAME_WIDTH=720
GAME_HEIGHT=1280
GAME_ASPECT=$(echo "scale=6; $GAME_WIDTH / $GAME_HEIGHT" | bc)

# Browser chrome offset (tabs + address bar) - calibrated for Dia browser
CHROME_HEIGHT=41

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

# Calculate game canvas bounds within the browser window
# Returns: canvas_x,canvas_y,canvas_w,canvas_h
get_canvas_bounds() {
    local win_x=$1
    local win_y=$2
    local win_w=$3
    local win_h=$4

    # Content area (excluding browser chrome)
    local content_x=$win_x
    local content_y=$((win_y + CHROME_HEIGHT))
    local content_w=$win_w
    local content_h=$((win_h - CHROME_HEIGHT))

    # Calculate canvas size maintaining 720:1280 aspect ratio
    local content_aspect=$(echo "scale=6; $content_w / $content_h" | bc)

    local canvas_w canvas_h
    # Compare aspects: if content is wider than game, height-constrained (black bars on sides)
    local is_wider=$(echo "$content_aspect > $GAME_ASPECT" | bc)

    if [ "$is_wider" -eq 1 ]; then
        # Height-constrained: canvas height = content height, width scaled
        canvas_h=$content_h
        canvas_w=$(echo "scale=0; $canvas_h * $GAME_ASPECT / 1" | bc)
    else
        # Width-constrained: canvas width = content width, height scaled
        canvas_w=$content_w
        canvas_h=$(echo "scale=0; $canvas_w / $GAME_ASPECT / 1" | bc)
    fi

    # Center canvas in content area
    local canvas_x=$((content_x + (content_w - canvas_w) / 2))
    local canvas_y=$((content_y + (content_h - canvas_h) / 2))

    echo "$canvas_x,$canvas_y,$canvas_w,$canvas_h"
}

# Get element positioning info
# Format: "anchor,x_pct,y_pct" where values are percentages of canvas size
# anchor: right = from right edge, center = from center
get_element_info() {
    local element=$1
    case $element in
        # Edge-anchored elements (percentage from canvas edge)
        # pause: ~5% from right, ~10% from top
        pause)       echo "right,0.09,0.095" ;;

        # Center-relative elements (percentage offset from center)
        start)       echo "center,0,.27" ;;
        green_fire)  echo "center,-0.07,0.45" ;;
        orange_fire) echo "center,0.33,0.44" ;;
        auto)        echo "center,-0.08,0.40" ;;
        blue_ball)   echo "center,-0.32,0.44" ;;
        resume)      echo "center,0,-.02" ;;
        sound)       echo "center,0,0" ;;
        quit)        echo "center,0,.04" ;;
        shop)        echo "center,-0.09,0.23" ;;
        restart)     echo "center,0.05,0.23" ;;
        close)       echo "center,0.00,0.34" ;;
        levelup_left)   echo "center,-.28,.03" ;;
        levelup_mid)    echo "center,0,.02" ;;
        levelup_right)  echo "center,.27,.03" ;;
        continue)       echo "center,0,.08" ;;
        play_again)     echo "center,0,.08" ;;
        next_char)      echo "center,.18,.21" ;;
        prev_char)      echo "center,-.18,.22" ;;
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
    local x_pct=$(echo $info_str | cut -d',' -f2)
    local y_pct=$(echo $info_str | cut -d',' -f3)

    local win_info=$(get_window_info)
    if [ -z "$win_info" ]; then
        echo "Error: Could not get Dia browser window info"
        return 1
    fi

    local win_x=$(echo $win_info | cut -d',' -f1)
    local win_y=$(echo $win_info | cut -d',' -f2)
    local win_w=$(echo $win_info | cut -d',' -f3)
    local win_h=$(echo $win_info | cut -d',' -f4)

    # Get canvas bounds
    local canvas_info=$(get_canvas_bounds $win_x $win_y $win_w $win_h)
    local canvas_x=$(echo $canvas_info | cut -d',' -f1)
    local canvas_y=$(echo $canvas_info | cut -d',' -f2)
    local canvas_w=$(echo $canvas_info | cut -d',' -f3)
    local canvas_h=$(echo $canvas_info | cut -d',' -f4)

    local click_x click_y

    case $anchor in
        right)
            # Percentage from right edge of canvas, percentage from top
            click_x=$(echo "scale=0; $canvas_x + $canvas_w - ($canvas_w * $x_pct) / 1" | bc)
            click_y=$(echo "scale=0; $canvas_y + ($canvas_h * $y_pct) / 1" | bc)
            ;;
        center|*)
            # Percentage offset from canvas center
            local center_x=$((canvas_x + canvas_w / 2))
            local center_y=$((canvas_y + canvas_h / 2))
            click_x=$(echo "scale=0; $center_x + ($canvas_w * $x_pct) / 1" | bc)
            click_y=$(echo "scale=0; $center_y + ($canvas_h * $y_pct) / 1" | bc)
            ;;
    esac

    echo "Clicking $element at ($click_x, $click_y) [canvas: ${canvas_w}x${canvas_h} at $canvas_x,$canvas_y]"
    cliclick c:$click_x,$click_y
}

# Calibrate an element by capturing mouse position
calibrate_element() {
    local element=$1
    local delay=${2:-4}

    echo "Hover over '$element' in $delay seconds..."
    sleep $delay

    local pos=$(cliclick p)
    local mouse_x=$(echo $pos | cut -d',' -f1)
    local mouse_y=$(echo $pos | cut -d',' -f2)

    echo "Captured position: ($mouse_x, $mouse_y)"

    # Get window and canvas info
    local win_info=$(get_window_info)
    if [ -z "$win_info" ]; then
        echo "Error: Could not get Dia browser window info"
        return 1
    fi

    local win_x=$(echo $win_info | cut -d',' -f1)
    local win_y=$(echo $win_info | cut -d',' -f2)
    local win_w=$(echo $win_info | cut -d',' -f3)
    local win_h=$(echo $win_info | cut -d',' -f4)

    local canvas_info=$(get_canvas_bounds $win_x $win_y $win_w $win_h)
    local canvas_x=$(echo $canvas_info | cut -d',' -f1)
    local canvas_y=$(echo $canvas_info | cut -d',' -f2)
    local canvas_w=$(echo $canvas_info | cut -d',' -f3)
    local canvas_h=$(echo $canvas_info | cut -d',' -f4)

    echo "Canvas: ${canvas_w}x${canvas_h} at ($canvas_x, $canvas_y)"

    # Calculate center-relative percentages
    local center_x=$((canvas_x + canvas_w / 2))
    local center_y=$((canvas_y + canvas_h / 2))
    local x_offset=$((mouse_x - center_x))
    local y_offset=$((mouse_y - center_y))
    local x_pct=$(echo "scale=2; $x_offset / $canvas_w" | bc)
    local y_pct=$(echo "scale=2; $y_offset / $canvas_h" | bc)

    echo ""
    echo "=== Center-relative (most elements) ==="
    echo "  x_pct: $x_pct  y_pct: $y_pct"
    echo "  Update script: $element) echo \"center,$x_pct,$y_pct\" ;;"

    # Calculate right-edge relative (for pause button style)
    local from_right=$((canvas_x + canvas_w - mouse_x))
    local from_top=$((mouse_y - canvas_y))
    local right_x_pct=$(echo "scale=2; $from_right / $canvas_w" | bc)
    local right_y_pct=$(echo "scale=2; $from_top / $canvas_h" | bc)

    echo ""
    echo "=== Right-edge relative (for edge buttons like pause) ==="
    echo "  from_right: $right_x_pct  from_top: $right_y_pct"
    echo "  Update script: $element) echo \"right,$right_x_pct,$right_y_pct\" ;;"
}

# Main
if [ -z "$1" ]; then
    echo "GoPit Game Clicker"
    echo "Usage: $0 <element_name> [count]"
    echo "       $0 calibrate <element_name> [delay_seconds]"
    echo ""
    echo "Elements:"
    echo "  Game:     pause, start, green_fire, orange_fire, auto, blue_ball"
    echo "  Menu:     resume, sound, quit"
    echo "  GameOver: shop, restart, close"
    echo "  LevelUp:  levelup_left, levelup_mid, levelup_right"
    echo "  Stage:    continue, play_again"
    echo "  CharSel:  start, next_char, prev_char"
    echo ""
    echo "Calibration:"
    echo "  ./click_game.sh calibrate green_fire    # Recalibrate green_fire (4s delay)"
    echo "  ./click_game.sh calibrate pause 5       # Recalibrate pause (5s delay)"
    exit 0
fi

# Handle calibrate command
if [ "$1" = "calibrate" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 calibrate <element_name> [delay_seconds]"
        exit 1
    fi
    calibrate_element "$2" "${3:-4}"
    exit 0
fi

element=$1
count=${2:-1}

for ((i=1; i<=count; i++)); do
    click_element "$element"
    [ $count -gt 1 ] && sleep 0.3
done
