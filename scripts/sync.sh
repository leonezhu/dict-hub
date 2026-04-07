#!/usr/bin/env bash
# Sync vocabulary files from Obsidian References to dict-hub/words/
# Usage: ./scripts/sync.sh

SOURCE_DIR="/Users/xiong/Documents/GitHub/notes/References"
TARGET_DIR="$(cd "$(dirname "$0")/.." && pwd)/words"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Syncing vocabulary files..."
echo "    Source: $SOURCE_DIR"
echo "    Target: $TARGET_DIR"

mkdir -p "$TARGET_DIR"

# Find .md files with [[Vocabulary]] in frontmatter only (between first two ---)
# Use awk to extract frontmatter then grep for the tag
vocab_files=$(awk '
    FNR==1 { fm=0; found=0 }
    /^---$/ { fm++; if (fm==2) { if(found) print FILENAME; next } if(fm==1) next }
    fm==1 && /\[\[Vocabulary\]\]/ { found=1 }
' "$SOURCE_DIR"/*.md 2>/dev/null | sort || true)

# Collect words into temp file (TSV: word<TAB>file<TAB>phonetic)
tmpfile=$(mktemp)
while IFS= read -r file; do
    [ -z "$file" ] && continue
    filename=$(basename "$file")
    cp "$file" "$TARGET_DIR/$filename"
    word="${filename%.md}"
    phonetic=$(/usr/bin/grep -m1 '音标' "$file" 2>/dev/null | /usr/bin/sed 's/.*| *//' | /usr/bin/sed 's/ *$//' || true)
    printf '%s\t%s\t%s\n' "$word" "$filename" "$phonetic" >> "$tmpfile"
done <<< "$vocab_files"

# Generate valid JSON with Python
python3 -c "
import json, sys
words = []
with open('$tmpfile') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split('\t', 2)
        words.append({'word': parts[0], 'file': parts[1], 'phonetic': parts[2] if len(parts) > 2 else ''})
json.dump(words, open('$REPO_DIR/words.json', 'w'), ensure_ascii=False, indent=2)
print(f'==> Found {len(words)} vocabulary files')
print('==> Generated words.json')
"

rm -f "$tmpfile"
echo "==> Done!"
