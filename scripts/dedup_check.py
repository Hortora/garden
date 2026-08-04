#!/usr/bin/env python3
"""Check new garden entries for duplicates against main branch corpus."""
import json
import os
import sqlite3
import subprocess
import sys
import tempfile

SIMILARITY_THRESHOLD = 0.8


def jaccard(set_a, set_b):
    if not set_a and not set_b:
        return 0.0
    intersection = set_a & set_b
    union = set_a | set_b
    return len(intersection) / len(union)


def tokenize(text):
    return set(text.lower().split())


def load_existing_entries(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.execute("SELECT id, title, tags FROM entries")
    entries = []
    for row in cursor:
        entry_id, title, tags = row
        tag_set = set(tags.split(",")) if tags else set()
        entries.append({"id": entry_id, "title": title, "tags": tag_set,
                        "title_tokens": tokenize(title)})
    conn.close()
    return entries


def parse_entry_frontmatter(filepath):
    title = ""
    tags = set()
    in_frontmatter = False
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if line == "---":
                if in_frontmatter:
                    break
                in_frontmatter = True
                continue
            if in_frontmatter:
                if line.startswith("title:"):
                    title = line.split(":", 1)[1].strip().strip('"').strip("'")
                elif line.startswith("tags:"):
                    raw = line.split(":", 1)[1].strip()
                    raw = raw.strip("[]")
                    tags = {t.strip().strip('"').strip("'")
                            for t in raw.split(",") if t.strip()}
    return title, tags


def main():
    if len(sys.argv) < 2:
        print("Usage: dedup_check.py <file1.md> [file2.md ...]",
              file=sys.stderr)
        sys.exit(2)

    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as tmp:
        tmp_db = tmp.name

    try:
        with open(tmp_db, "wb") as f:
            result = subprocess.run(
                ["git", "show", "main:garden.db"],
                stdout=f, stderr=subprocess.DEVNULL)
        if result.returncode != 0:
            print(json.dumps({"duplicates": [], "skipped": True,
                              "reason": "garden.db not found on main"}))
            sys.exit(0)

        existing = load_existing_entries(tmp_db)
    finally:
        os.unlink(tmp_db)

    duplicates = []
    for filepath in sys.argv[1:]:
        if not os.path.exists(filepath):
            continue
        title, tags = parse_entry_frontmatter(filepath)
        if not title:
            continue
        title_tokens = tokenize(title)
        for entry in existing:
            title_sim = jaccard(title_tokens, entry["title_tokens"])
            tag_sim = (jaccard(tags, entry["tags"])
                       if tags and entry["tags"] else 0.0)
            combined = 0.7 * title_sim + 0.3 * tag_sim
            if combined >= SIMILARITY_THRESHOLD:
                duplicates.append({
                    "new": os.path.basename(filepath),
                    "existing": entry["id"],
                    "similarity": round(combined, 3),
                })

    print(json.dumps({"duplicates": duplicates}, indent=2))
    sys.exit(1 if duplicates else 0)


if __name__ == "__main__":
    main()
