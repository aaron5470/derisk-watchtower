---
description: Scan staged changes to suggest AI_USAGE.md entries. Usage: /ai-usage scan
---

# /ai-usage scan

Goal: Produce a checklist of staged code files that likely need AI_USAGE.md entries.

Heuristics:
- Prefer `git diff --cached --name-only --diff-filter=ACMR` if a git repo is present.
- Focus on typical code paths: `contracts/**, backend/**, frontend/**, api/**, cmd/**, pkg/**, internal/**, ui/**`
  and extensions: `.sol, .go, .ts, .tsx, .js, .jsx, .py, .rs, .java, .kt, .cs, .cpp, .c`.
- Print a simple table: `path | suggested line`.

Do not modify files; only print recommendations.