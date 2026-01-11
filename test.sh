#!/usr/bin/env bash
# PlayGodot Test Runner for GoPit
# Usage: ./test.sh [pytest arguments]
#
# Parallel execution (default):
#   ./test.sh                    # Runs with 4 workers
#   ./test.sh -n 8               # Override to 8 workers
#   ./test.sh -n 0               # Disable parallel (sequential)
#
# Single file (no parallel):
#   ./test.sh tests/test_fire.py

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== GoPit PlayGodot Test Runner ==="
cd "$SCRIPT_DIR"

# Activate venv if not already active
if [ -z "$VIRTUAL_ENV" ] && [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Default number of parallel workers
WORKERS=${TEST_WORKERS:-4}

# Check if running specific file(s) or if -n already specified
if [[ "$*" == *"tests/"* ]] || [[ "$*" == *"-n "* ]] || [[ "$*" == *"-n0"* ]]; then
    # Running specific file or -n already specified - don't add parallel flag
    python3 -m pytest tests/ -v --tb=short "$@"
else
    # Running all tests - use parallel execution
    python3 -m pytest tests/ -v --tb=short -n "$WORKERS" "$@"
fi
