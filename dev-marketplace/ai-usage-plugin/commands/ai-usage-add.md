---
description: Append one standardized line to AI_USAGE.md. Usage: /ai-usage add <path[#Method]>
---

# /ai-usage add

Append **one line** to repo-root `AI_USAGE.md` with the format:

`YYYY-MM-DD | <Tool> | <path[#Method]> | owner=<human|ai> review=<INITIALS|none> | <notes>`

Do:
1) Ensure `AI_USAGE.md` exists at repository root (create if missing).
2) Keep `<path[#Method]>` as given (no absolute path).
3) Use today's date (YYYY-MM-DD). Default `<Tool>` to `Claude` unless user specifies.
4) If the same line already exists, do nothing; otherwise append exactly one new line.
5) Show the final appended line to the user.

**Note:** This command **does not stage** the file. After it finishes, the user will run `git add AI_USAGE.md` before `git commit`.