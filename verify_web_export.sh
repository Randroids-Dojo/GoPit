#!/usr/bin/env bash
# Web Export Verification Script for GoPit
# Usage: ./verify_web_export.sh [--serve]
#
# This script:
# 1. Verifies Godot is available
# 2. Exports the game for web
# 3. Validates the build output
# 4. Optionally serves the build for manual testing
#
# Options:
#   --serve     Start a local server after build for manual testing
#   --clean     Remove existing build directory before export
#
# For browser testing, you MUST use a local server due to CORS restrictions.
# The script will offer to start one automatically.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVE_AFTER=false
CLEAN_FIRST=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --serve)
            SERVE_AFTER=true
            ;;
        --clean)
            CLEAN_FIRST=true
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--serve] [--clean]"
            exit 1
            ;;
    esac
done

echo "=== GoPit Web Export Verification ==="
echo ""

# Step 1: Find Godot
echo "Step 1: Locating Godot..."

GODOT_PATH=""

# Check .godot-path file first
if [ -f ".godot-path" ]; then
    GODOT_PATH=$(cat .godot-path | tr -d '[:space:]')
    if [ -x "$GODOT_PATH" ]; then
        echo -e "  ${GREEN}Found Godot from .godot-path:${NC} $GODOT_PATH"
    else
        GODOT_PATH=""
    fi
fi

# Check environment variable
if [ -z "$GODOT_PATH" ] && [ -n "$GODOT_PATH" ]; then
    if [ -x "$GODOT_PATH" ]; then
        echo -e "  ${GREEN}Found Godot from env:${NC} $GODOT_PATH"
    else
        GODOT_PATH=""
    fi
fi

# Check sibling directory (common development setup)
if [ -z "$GODOT_PATH" ]; then
    SIBLING_PATH="../godot/bin/godot.macos.editor.arm64"
    if [ -x "$SIBLING_PATH" ]; then
        GODOT_PATH="$SIBLING_PATH"
        echo -e "  ${GREEN}Found Godot in sibling dir:${NC} $GODOT_PATH"
    fi
fi

# Check common macOS locations
if [ -z "$GODOT_PATH" ]; then
    for path in \
        "/Applications/Godot.app/Contents/MacOS/Godot" \
        "/Applications/Godot_mono.app/Contents/MacOS/Godot" \
        "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
    do
        if [ -x "$path" ]; then
            GODOT_PATH="$path"
            echo -e "  ${GREEN}Found Godot:${NC} $GODOT_PATH"
            break
        fi
    done
fi

# Check if godot is in PATH
if [ -z "$GODOT_PATH" ]; then
    if command -v godot &> /dev/null; then
        GODOT_PATH="godot"
        echo -e "  ${GREEN}Found Godot in PATH${NC}"
    fi
fi

if [ -z "$GODOT_PATH" ]; then
    echo -e "  ${RED}ERROR: Godot not found${NC}"
    echo ""
    echo "  Please install Godot or set one of:"
    echo "    - Create .godot-path file with path to Godot binary"
    echo "    - Set GODOT_PATH environment variable"
    echo "    - Add godot to your PATH"
    exit 1
fi

# Step 2: Clean build directory if requested
if [ "$CLEAN_FIRST" = true ] && [ -d "build" ]; then
    echo ""
    echo "Step 2: Cleaning build directory..."
    rm -rf build
    echo -e "  ${GREEN}Removed existing build directory${NC}"
fi

# Step 3: Import project (required before export)
echo ""
echo "Step 3: Importing Godot project..."
"$GODOT_PATH" --headless --import . --quit 2>&1 || true
echo -e "  ${GREEN}Import complete${NC}"

# Step 4: Export for web
echo ""
echo "Step 4: Exporting for web..."
mkdir -p build

EXPORT_LOG=$(mktemp)
if "$GODOT_PATH" --headless --export-release "Web" ./build/index.html 2>&1 | tee "$EXPORT_LOG"; then
    echo ""
else
    echo -e "  ${RED}Export command failed${NC}"
    cat "$EXPORT_LOG"
    rm "$EXPORT_LOG"
    exit 1
fi

# Check for errors in export log
if grep -qi "error" "$EXPORT_LOG"; then
    echo -e "  ${YELLOW}WARNING: Export log contains errors:${NC}"
    grep -i "error" "$EXPORT_LOG"
fi
rm "$EXPORT_LOG"

# Step 5: Validate build output
echo ""
echo "Step 5: Validating build output..."

REQUIRED_FILES=(
    "build/index.html"
    "build/index.js"
    "build/index.wasm"
    "build/index.pck"
)

ALL_PRESENT=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(ls -lh "$file" | awk '{print $5}')
        echo -e "  ${GREEN}[OK]${NC} $file ($SIZE)"
    else
        echo -e "  ${RED}[MISSING]${NC} $file"
        ALL_PRESENT=false
    fi
done

# Check optional files
OPTIONAL_FILES=(
    "build/index.icon.png"
    "build/index.apple-touch-icon.png"
    "build/index.audio.worklet.js"
    "build/index.audio.position.worklet.js"
)

echo ""
echo "  Optional files:"
for file in "${OPTIONAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(ls -lh "$file" | awk '{print $5}')
        echo -e "  ${GREEN}[OK]${NC} $file ($SIZE)"
    else
        echo -e "  ${YELLOW}[MISSING]${NC} $file (optional)"
    fi
done

if [ "$ALL_PRESENT" = false ]; then
    echo ""
    echo -e "${RED}BUILD FAILED: Required files missing${NC}"
    exit 1
fi

# Step 6: Calculate total build size
echo ""
echo "Step 6: Build statistics..."
TOTAL_SIZE=$(du -sh build | awk '{print $1}')
echo -e "  Total build size: ${GREEN}$TOTAL_SIZE${NC}"

# Count files
FILE_COUNT=$(find build -type f | wc -l | tr -d ' ')
echo "  Total files: $FILE_COUNT"

# Step 7: Summary
echo ""
echo "========================================="
echo -e "  ${GREEN}WEB EXPORT SUCCESSFUL${NC}"
echo "========================================="
echo ""
echo "  Build location: $(pwd)/build/"
echo "  Main file: build/index.html"
echo ""

# Step 8: Serve if requested
if [ "$SERVE_AFTER" = true ]; then
    echo "Starting local server..."
    echo ""
    echo "  Open in browser: http://localhost:8000"
    echo "  Press Ctrl+C to stop"
    echo ""

    # Use Python's built-in server (handles CORS headers needed for Godot web)
    cd build
    python3 -c "
import http.server
import socketserver

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

PORT = 8000
with socketserver.TCPServer(('', PORT), CORSRequestHandler) as httpd:
    print(f'Serving at http://localhost:{PORT}')
    httpd.serve_forever()
"
else
    echo "Manual testing:"
    echo "  1. Run: ./verify_web_export.sh --serve"
    echo "  2. Open: http://localhost:8000"
    echo "  3. See: docs/web-testing-checklist.md for testing guide"
    echo ""
    echo "Or deploy to Vercel:"
    echo "  vercel deploy build/"
fi
