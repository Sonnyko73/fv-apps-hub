#!/usr/bin/env bash
# Copies build-required assets from the Shared-assets source of truth
# (Google Drive) into the project's committed Shared-assets-git/ directory.
#
# Run this when shared assets change, then commit the result:
#   bash scripts/sync-assets.sh
#   git add Shared-assets-git/
#   git commit -m "chore: sync assets from source of truth"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source: the Shared-assets symlink in the project root (points to Google Drive)
SRC="$PROJECT_ROOT/Shared-assets"
DEST="$PROJECT_ROOT/Shared-assets-git"

if [ ! -d "$SRC" ] && [ ! -L "$SRC" ]; then
  echo "Error: Shared-assets symlink not found at $SRC"
  echo "This script must be run locally where the Google Drive symlink exists."
  exit 1
fi

if [ ! -d "$(readlink -f "$SRC" 2>/dev/null || echo "$SRC")" ]; then
  echo "Error: Shared-assets symlink target does not exist."
  echo "Make sure Google Drive is synced and the Shared-assets folder is accessible."
  exit 1
fi

echo "Syncing from: $SRC"
echo "Syncing to:   $DEST"

# Global assets
rsync -av "$SRC/assets/favicon.ico"     "$DEST/assets/"
rsync -av "$SRC/assets/fv-logo.png"     "$DEST/assets/"

# App-specific assets (export-ready only)
rsync -av --include='*.png' --include='*.svg' --exclude='*' \
  "$SRC/apps-assets/seo-redirect-logo/" "$DEST/assets/" 2>/dev/null || true

# Styles (if any exist in source — CSS files may be authored locally)
if ls "$SRC/styles/"*.css 1>/dev/null 2>&1; then
  rsync -av "$SRC/styles/"*.css "$DEST/styles/"
fi

# Components (if any exist in source)
if ls "$SRC/components/"*.css 1>/dev/null 2>&1; then
  rsync -av "$SRC/components/"*.css "$DEST/components/"
fi

echo ""
echo "Done. Review changes with: git diff Shared-assets-git/"
echo "Then commit: git add Shared-assets-git/ && git commit -m 'chore: sync assets from source of truth'"
