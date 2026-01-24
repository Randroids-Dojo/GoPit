#!/bin/bash
# Install dots CLI tool for task management
# https://github.com/joelreymont/dots
#
# Security: Pinned to specific version with SHA256 verification

set -e

# Pinned version and checksums (update these when upgrading)
DOTS_VERSION="0.6.4"
CHECKSUM_LINUX_X86_64="2008db695f375ca29475b82250c5d71d51c8e3ed0f63ffcaf710a6628c5ce578"
CHECKSUM_MACOS_ARM64="a8f749aba34d90ada89e81a3b29096381361c410289f06c6e864db28825d1fbc"

INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

# Skip if already installed with correct version
if command -v dot &> /dev/null; then
  INSTALLED_VERSION=$(dot --version 2>/dev/null | head -1 | awk '{print $2}')
  if [ "$INSTALLED_VERSION" = "$DOTS_VERSION" ]; then
    exit 0
  fi
fi

# Also check the install directory directly
if [ -x "$INSTALL_DIR/dot" ]; then
  INSTALLED_VERSION=$("$INSTALL_DIR/dot" --version 2>/dev/null | head -1 | awk '{print $2}')
  if [ "$INSTALLED_VERSION" = "$DOTS_VERSION" ]; then
    # Ensure PATH is set for this session
    if [ -n "$CLAUDE_ENV_FILE" ]; then
      echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
    fi
    exit 0
  fi
fi

# Determine platform and expected checksum
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS-$ARCH" in
  linux-x86_64)
    BINARY="dot-linux-x86_64"
    EXPECTED_CHECKSUM="$CHECKSUM_LINUX_X86_64"
    ;;
  darwin-arm64)
    BINARY="dot-macos-arm64"
    EXPECTED_CHECKSUM="$CHECKSUM_MACOS_ARM64"
    ;;
  *)
    echo "Unsupported platform: $OS-$ARCH" >&2
    exit 0  # Don't fail the session, just skip
    ;;
esac

# Require checksum for security
if [ -z "$EXPECTED_CHECKSUM" ]; then
  echo "No checksum available for $BINARY - skipping install for security" >&2
  exit 0
fi

# Download from pinned version
DOWNLOAD_URL="https://github.com/joelreymont/dots/releases/download/v${DOTS_VERSION}/${BINARY}"
TEMP_FILE=$(mktemp)
trap "rm -f '$TEMP_FILE'" EXIT

curl -sL "$DOWNLOAD_URL" -o "$TEMP_FILE"

# Verify checksum
ACTUAL_CHECKSUM=$(sha256sum "$TEMP_FILE" | awk '{print $1}')
if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
  echo "Checksum verification failed for dots binary!" >&2
  echo "Expected: $EXPECTED_CHECKSUM" >&2
  echo "Actual:   $ACTUAL_CHECKSUM" >&2
  exit 1
fi

# Install verified binary
mv "$TEMP_FILE" "$INSTALL_DIR/dot"
chmod +x "$INSTALL_DIR/dot"

# Persist PATH for subsequent bash commands in this session
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

exit 0
