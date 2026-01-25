#!/bin/bash
# Setup Godot automation fork + PlayGodot for testing
# Ensures consistent test environment across all Claude Code sessions
#
# This hook is idempotent and safe to run multiple times
# Downloads pre-built binaries from GitHub releases (preferred)
# Falls back to building from source if needed

set -e

# Installation directory (customize per project if needed)
WORK_DIR="${HOME}/.local/share/gopit"
GODOT_DIR="${WORK_DIR}/godot-bin"
PLAYGODOT_DIR="${WORK_DIR}/PlayGodot"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

mkdir -p "$WORK_DIR"

# Determine platform and binary info
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS-$ARCH" in
  linux-x86_64)
    GODOT_BINARY="godot.linuxbsd.editor.x86_64.mono"
    RELEASE_ASSET="godot-automation-linux-x86_64.zip"
    EXPECTED_SHA256="e9981195f1051f8c18d2f5bbee7010787f92185a1584d4e694ad58e36f468b60"
    ;;
  darwin-arm64|darwin-x86_64)
    GODOT_BINARY="Godot.app/Contents/MacOS/Godot"
    RELEASE_ASSET="godot-automation-macos-universal.zip"
    EXPECTED_SHA256=""  # Universal binary, checksum may vary
    ;;
  *)
    echo "Unsupported platform: $OS-$ARCH" >&2
    exit 0  # Don't fail the session
    ;;
esac

GODOT_PATH="${GODOT_DIR}/${GODOT_BINARY}"

# 0. Install .NET SDK 8.0 if needed (required for mono build on Linux)
if [ "$OS" = "linux" ]; then
  DOTNET_ROOT="${HOME}/.dotnet"
  if ! command -v dotnet &> /dev/null && [ ! -x "${DOTNET_ROOT}/dotnet" ]; then
    echo "Installing .NET SDK 8.0 (required for Godot mono build)..."
    mkdir -p "$DOTNET_ROOT"
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 8.0 --install-dir "$DOTNET_ROOT"
  fi

  # Ensure .NET is in PATH for this session
  if [ -n "$CLAUDE_ENV_FILE" ] && [ -d "$DOTNET_ROOT" ]; then
    echo "export DOTNET_ROOT=\"${DOTNET_ROOT}\"" >> "$CLAUDE_ENV_FILE"
    echo "export PATH=\"${DOTNET_ROOT}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
  fi
  export PATH="${DOTNET_ROOT}:$PATH"
  export DOTNET_ROOT="${DOTNET_ROOT}"
fi

# 1. Download pre-built Godot binary if not present
if [ ! -f "$GODOT_PATH" ]; then
  echo "Downloading Godot automation fork (pre-built binary)..."
  mkdir -p "$GODOT_DIR"

  DOWNLOAD_URL="https://github.com/Randroids-Dojo/godot/releases/download/automation-latest/${RELEASE_ASSET}"
  TEMP_ZIP=$(mktemp)
  trap "rm -f '$TEMP_ZIP'" EXIT

  curl -sL "$DOWNLOAD_URL" -o "$TEMP_ZIP"

  # Verify checksum if available
  if [ -n "$EXPECTED_SHA256" ]; then
    ACTUAL_SHA256=$(sha256sum "$TEMP_ZIP" | awk '{print $1}')
    if [ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]; then
      echo "Checksum verification failed for Godot binary!" >&2
      echo "Expected: $EXPECTED_SHA256" >&2
      echo "Actual:   $ACTUAL_SHA256" >&2
      exit 1
    fi
    echo "Checksum verified successfully"
  fi

  # Extract to godot directory
  unzip -q -o "$TEMP_ZIP" -d "$GODOT_DIR"
  chmod +x "$GODOT_PATH"

  echo "Godot binary installed: $GODOT_PATH"
fi

# 2. Clone PlayGodot if not present
if [ ! -d "$PLAYGODOT_DIR" ]; then
  echo "Cloning PlayGodot..."
  git clone --depth 1 https://github.com/Randroids-Dojo/PlayGodot.git "$PLAYGODOT_DIR"
fi

# 3. Setup Python venv and install PlayGodot
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
  pip install -q -e "${PLAYGODOT_DIR}/python"
fi

# Install test dependencies if not present
if ! python3 -c "import pytest" 2>/dev/null; then
  echo "Installing test dependencies..."
  pip install -q pytest pytest-asyncio pytest-xdist
fi

# 4. Import project to generate .godot cache (required before running tests)
if [ ! -d "${PROJECT_DIR}/.godot/imported" ]; then
  echo "Importing Godot project..."
  timeout 120 "$GODOT_PATH" --path "$PROJECT_DIR" --import --headless 2>/dev/null || true
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
