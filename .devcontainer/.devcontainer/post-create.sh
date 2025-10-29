#!/usr/bin/env bash
set -euo pipefail

echo "[post-create] Detecting and restoring dependencies..."

# Node
if [ -f package.json ]; then
  corepack enable || true
  if command -v pnpm >/dev/null 2>&1; then
    pnpm install
  elif command -v yarn >/dev/null 2>&1; then
    yarn install
  else
    npm install
  fi
fi

# Python
if [ -f requirements.txt ]; then
  python3 -m venv .venv && . .venv/bin/activate && pip install -U pip && pip install -r requirements.txt
fi

# .NET
if compgen -G "*.sln" > /dev/null; then
  dotnet restore
fi

echo "[post-create] Done."
