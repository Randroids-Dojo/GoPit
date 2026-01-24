#!/bin/bash
# Setup Godot automation fork + PlayGodot for testing
# Ensures consistent test environment across all Claude Code sessions
#
# This hook is idempotent and safe to run multiple times

set -e

# Installation directory (customize per project if needed)
WORK_DIR="${HOME}/.local/share/gopit"
GODOT_DIR="${WORK_DIR}/godot"
PLAYGODOT_DIR="${WORK_DIR}/PlayGodot"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

mkdir -p "$WORK_DIR"

# Determine platform and binary name
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS-$ARCH" in
  linux-x86_64)
    GODOT_BINARY="godot.linuxbsd.editor.x86_64"
    ;;
  darwin-arm64)
    GODOT_BINARY="godot.macos.editor.arm64"
    ;;
  darwin-x86_64)
    GODOT_BINARY="godot.macos.editor.x86_64"
    ;;
  *)
    echo "Unsupported platform: $OS-$ARCH" >&2
    exit 0  # Don't fail the session
    ;;
esac

GODOT_PATH="${GODOT_DIR}/bin/${GODOT_BINARY}"

# 1. Clone Godot automation fork if not present
if [ ! -d "$GODOT_DIR" ]; then
  echo "Cloning Godot automation fork..."
  git clone --depth 1 --branch automation https://github.com/Randroids-Dojo/godot.git "$GODOT_DIR"
fi

# 2. Build Godot if binary doesn't exist
if [ ! -f "$GODOT_PATH" ]; then
  echo "Building Godot automation fork..."
  cd "$GODOT_DIR"

  case "$OS-$ARCH" in
    linux-x86_64)
      scons platform=linuxbsd target=editor -j$(nproc) 2>&1 | tail -20
      ;;
    darwin-arm64)
      scons platform=macos arch=arm64 target=editor -j$(sysctl -n hw.ncpu) 2>&1 | tail -20
      ;;
    darwin-x86_64)
      scons platform=macos arch=x86_64 target=editor -j$(sysctl -n hw.ncpu) 2>&1 | tail -20
      ;;
  esac

  cd "$PROJECT_DIR"
fi

# 3. Clone PlayGodot if not present
if [ ! -d "$PLAYGODOT_DIR" ]; then
  echo "Cloning PlayGodot..."
  git clone --depth 1 https://github.com/Randroids-Dojo/PlayGodot.git "$PLAYGODOT_DIR"
fi

# 4. Setup Python venv and install PlayGodot
VENV_DIR="${PROJECT_DIR}/.venv"

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating Python virtual environment..."
  python3 -m venv "$VENV_DIR"
fi

# Activate venv and install dependencies
source "${VENV_DIR}/bin/activate"

# Install PlayGodot from local clone (editable mode for development)
if ! python3 -c "import playgodot" 2>/dev/null; then
  echo "Installing PlayGodot..."
  pip install -q -e "$PLAYGODOT_DIR"
fi

# Install test dependencies if not present
if ! python3 -c "import pytest" 2>/dev/null; then
  echo "Installing test dependencies..."
  pip install -q pytest pytest-asyncio pytest-xdist
fi

# 5. Set GODOT_PATH for this session
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export GODOT_PATH=\"${GODOT_PATH}\"" >> "$CLAUDE_ENV_FILE"
  echo "export PATH=\"${VENV_DIR}/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# 6. Create .godot-path file in project root if not exists
if [ ! -f "${PROJECT_DIR}/.godot-path" ]; then
  echo "$GODOT_PATH" > "${PROJECT_DIR}/.godot-path"
fi

echo "Godot + PlayGodot setup complete!"
echo "Godot binary: $GODOT_PATH"
echo "PlayGodot: $PLAYGODOT_DIR"

exit 0
