#!/usr/bin/env bash
# PlayGodot Test Runner for GoPit
# Usage: ./test.sh [pytest arguments]

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== GoPit PlayGodot Test Runner ==="
cd "$SCRIPT_DIR"

# Activate venv if not already active
if [ -z "$VIRTUAL_ENV" ] && [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Run tests - conftest.py handles GODOT_PATH discovery
python3 -m pytest tests/ -v --tb=short "$@"
