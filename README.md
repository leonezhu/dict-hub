# Dict Hub

Personal vocabulary notebook, synced from Obsidian and deployed to GitHub Pages.

**Live:** [leonezhu.github.io/dict-hub](https://leonezhu.github.io/dict-hub/)

## Quick Start

```bash
# Sync & deploy (one step)
./scripts/deploy.sh

# Sync only (no commit/push)
./scripts/sync.sh
```

## Structure

```
dict-hub/
├── index.html        # GitHub Pages frontend
├── words.json        # Word index (auto-generated)
├── words/            # Vocabulary markdown files (auto-synced)
├── scripts/
│   ├── sync.sh       # Sync from Obsidian → words/
│   └── deploy.sh     # Sync + commit + push
└── .nojekyll
```

## How It Works

1. `sync.sh` scans `/Users/xiong/Documents/GitHub/notes/References/` for `.md` files with `[[Vocabulary]]` in frontmatter
2. Copies them to `words/` and generates `words.json`
3. `deploy.sh` runs sync, then commits and pushes to GitHub
4. GitHub Pages serves `index.html` which renders all words client-side

## Features

- Search and filter words
- Mermaid diagram support
- Dark/light mode auto-switch
- URL hash navigation (shareable links)
