#!/bin/bash
# Install git pre-commit hook for running tests
# Called by SessionStart to ensure agents have test feedback

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
HOOK_TARGET="$PROJECT_DIR/.git/hooks/pre-commit"

# Skip if hook already exists
if [ -f "$HOOK_TARGET" ]; then
    exit 0
fi

# Create the pre-commit hook
cat > "$HOOK_TARGET" << 'HOOK_SCRIPT'
#!/bin/bash
# Pre-commit hook: Run PlayGodot tests before allowing commits
# Skip with: git commit --no-verify (or -n)

set -e

echo "=== Running pre-commit tests ==="

# Check if we're in the right directory
if [ ! -f "./test.sh" ]; then
    echo "Warning: test.sh not found, skipping tests"
    exit 0
fi

# Check if venv exists
if [ ! -d ".venv" ]; then
    echo "Warning: .venv not found - tests require PlayGodot environment"
    echo "Run setup-godot-playgodot.sh or skip with: git commit --no-verify"
    exit 1
fi

# Run tests (sequential for pre-commit to be faster on small changes)
echo "Running tests..."
if ./test.sh -n 0 2>&1; then
    echo "=== Tests passed ==="
    exit 0
else
    echo ""
    echo "=== Tests FAILED ==="
    echo "Fix the failing tests before committing."
    echo "To skip this check: git commit --no-verify"
    exit 1
fi
HOOK_SCRIPT

chmod +x "$HOOK_TARGET"
echo "Pre-commit hook installed"
exit 0
