#!/usr/bin/env bash
# Launches the mysql-local MCP server for Claude Desktop.
# Credentials live in mysql-local.env (untracked) next to this repo, never in
# claude_desktop_config.json and never in chat.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_DIR/mysql-local.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE." >&2
  echo "Copy mysql-local.env.example to mysql-local.env and fill in the five database values, then try again." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

for var in MYSQL_HOST MYSQL_PORT MYSQL_USER MYSQL_PASS MYSQL_DB; do
  if [ -z "${!var:-}" ]; then
    echo "mysql-local.env is missing a value for $var. Fill in all five fields and try again." >&2
    exit 1
  fi
done

# Widen PATH so this works when launched by a GUI app (Claude Desktop) that
# doesn't inherit a shell's PATH additions from Homebrew, nvm, etc.
for extra in /opt/homebrew/bin /usr/local/bin "$HOME/.nvm/versions/node/*/bin"; do
  for p in $extra; do
    [ -d "$p" ] && PATH="$p:$PATH"
  done
done
export PATH

NPX_BIN="$(command -v npx || true)"
if [ -z "$NPX_BIN" ]; then
  echo "Could not find npx on PATH. Install Node.js LTS, then try again." >&2
  exit 1
fi

exec "$NPX_BIN" -y @benborla29/mcp-server-mysql@2.0.9
