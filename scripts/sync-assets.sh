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

WARNINGS=0

# Helper: sync a required file, warn if missing
sync_required() {
  local src_file="$1"
  local dest_dir="$2"
  if [ -f "$src_file" ]; then
    rsync -av "$src_file" "$dest_dir"
  else
    echo "WARNING: Required asset missing: $src_file"
    WARNINGS=$((WARNINGS + 1))
  fi
}

# Global assets
sync_required "$SRC/assets/favicon.ico"  "$DEST/assets/"
sync_required "$SRC/assets/fv-logo.png"  "$DEST/assets/"
sync_required "$SRC/assets/og.png"       "$DEST/assets/"

# App-specific assets (export-ready only)
APP_LOGO_DIR="$SRC/apps-assets/seo-redirect-logo"
if [ -d "$APP_LOGO_DIR" ]; then
  rsync -av --include='*.png' --include='*.svg' --exclude='*' \
    "$APP_LOGO_DIR/" "$DEST/assets/"
  # Warn if app OG is missing
  if [ ! -f "$APP_LOGO_DIR/og.png" ]; then
    echo "WARNING: App OG image missing: $APP_LOGO_DIR/og.png"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "WARNING: App logo directory not found: $APP_LOGO_DIR"
  WARNINGS=$((WARNINGS + 1))
fi

# Styles (if any exist in source — CSS files may be authored locally)
if ls "$SRC/styles/"*.css 1>/dev/null 2>&1; then
  rsync -av "$SRC/styles/"*.css "$DEST/styles/"
fi

# Components (if any exist in source)
if ls "$SRC/components/"*.css 1>/dev/null 2>&1; then
  rsync -av "$SRC/components/"*.css "$DEST/components/"
fi

echo ""
if [ "$WARNINGS" -gt 0 ]; then
  echo "Done with $WARNINGS warning(s). Fix missing assets before committing."
else
  echo "Done. Review changes with: git diff Shared-assets-git/"
  echo "Then commit: git add Shared-assets-git/ && git commit -m 'chore: sync assets from source of truth'"
fi
