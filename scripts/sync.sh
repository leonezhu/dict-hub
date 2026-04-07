#!/usr/bin/env bash
# Sync vocabulary files from Obsidian References to dict-hub/words/
# Usage: ./scripts/sync.sh

SOURCE_DIR="/Users/xiong/Documents/GitHub/notes/References"
TARGET_DIR="$(cd "$(dirname "$0")/.." && pwd)/words"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Syncing vocabulary files..."
echo "    Source: $SOURCE_DIR"
echo "    Target: $TARGET_DIR"

# Create target directory
mkdir -p "$TARGET_DIR"

# Find all .md files with [[Vocabulary]] in frontmatter
vocab_files=$(/usr/bin/grep -rl '\[\[Vocabulary\]\]' "$SOURCE_DIR"/*.md 2>/dev/null | sort || true)

count=0
manifest="["
first=true

while IFS= read -r file; do
    [ -z "$file" ] && continue
    count=$((count + 1))

    filename=$(basename "$file")
    cp "$file" "$TARGET_DIR/$filename"

    # Extract word from filename (remove .md extension)
    word="${filename%.md}"

    # Extract phonetic from file if available
    phonetic=""
    if [[ -f "$file" ]]; then
        phonetic=$(/usr/bin/grep -m1 '音标' "$file" 2>/dev/null | /usr/bin/sed 's/.*| *//' | /usr/bin/sed 's/ *$//' || true)
    fi

    if [ "$first" = true ]; then
        first=false
    else
        manifest+=","
    fi
    manifest+="{\"word\":\"$word\",\"file\":\"$filename\",\"phonetic\":\"$phonetic\"}"
done <<< "$vocab_files"

manifest+="]"

echo "$manifest" > "$REPO_DIR/words.json"

echo "==> Found $count vocabulary files"
echo "==> Generated words.json"
echo "==> Done!"
