#!/usr/bin/env bash
#
# Bootstrap a brand-new MCP server from this skeleton.
#
# Usage:
#   scripts/new-mcp.sh <module-name> [target-dir]
#
# Examples:
#   scripts/new-mcp.sh my-cool-mcp                 # -> ../my-cool-mcp
#   scripts/new-mcp.sh github.com/me/notes-mcp ~/src/notes-mcp
#
# The new project is a self-contained copy: the mcpkit toolkit, the entry
# point, and the example ping/echo tools (keep them as templates, delete what
# you don't need). Import paths and the module are rewritten to <module-name>.
set -euo pipefail

MODULE="${1:-}"
if [ -z "$MODULE" ]; then
  echo "usage: scripts/new-mcp.sh <module-name> [target-dir]" >&2
  exit 1
fi

# Default the directory to a sibling named after the last path segment.
TARGET="${2:-../$(basename "$MODULE")}"
SRC="$(cd "$(dirname "$0")/.." && pwd)"

# module to rewrite, read from this skeleton's go.mod
OLD_MODULE="$(awk '/^module /{print $2}' "$SRC/go.mod")"
if [ -z "$OLD_MODULE" ]; then
  echo "error: could not read module name from $SRC/go.mod" >&2
  exit 1
fi

if [ -e "$TARGET" ]; then
  echo "error: target '$TARGET' already exists" >&2
  exit 1
fi

echo ">> creating $TARGET (module: $MODULE)"
mkdir -p "$TARGET"

# Copy the source tree, skipping git history, build output, and skeleton-only files.
cp -R "$SRC/cmd" "$SRC/internal" "$TARGET/"
[ -f "$SRC/.gitignore" ] && cp "$SRC/.gitignore" "$TARGET/"

# Rewrite every reference to the old module (import paths, server name, etc.).
# '#' delimiter so module paths containing '/' work as replacements.
grep -rl "$OLD_MODULE" "$TARGET" | while IFS= read -r f; do
  sed -i.bak "s#${OLD_MODULE}#${MODULE}#g" "$f"
  rm -f "$f.bak"
done

# Fresh module file + resolve dependencies + prove it compiles.
(
  cd "$TARGET"
  go mod init "$MODULE" >/dev/null 2>&1 || true
  go mod tidy
  go build ./...
)

echo ">> done. next steps:"
echo "     cd $TARGET"
echo "     go run ./cmd/server      # serves over stdio"
echo "     # edit internal/tools/*.go to add your own tools"
