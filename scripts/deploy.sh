#!/usr/bin/env bash
# Sync vocabulary files and deploy to GitHub Pages
# Usage: ./scripts/deploy.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_DIR"

# Sync vocabulary files
echo "==> Syncing vocabulary files..."
bash "$SCRIPT_DIR/sync.sh"

# Check if there are changes
if git diff --quiet && git diff --cached --quiet; then
    echo "==> No changes to commit."
    exit 0
fi

# Stage all changes
git add words/ words.json index.html scripts/ README.md .nojekyll

# Commit
WORD_COUNT=$(python3 -c "import json; print(len(json.load(open('$REPO_DIR/words.json'))))")
COMMIT_MSG="sync: update vocabulary ($WORD_COUNT words) — $(date '+%Y-%m-%d %H:%M')"

git commit -m "$COMMIT_MSG"

# Push
echo "==> Pushing to origin..."
git push origin main

echo "==> Deployed! View at https://leonezhu.github.io/dict-hub/"
