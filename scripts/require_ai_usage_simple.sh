#!/usr/bin/env bash
set -euo pipefail

# 1) 这次提交里被暂存(staged)的代码文件
changed_files="$(git diff --cached --name-only --diff-filter=ACMR \
  | grep -E '(^contracts/|^backend/|^frontend/|^api/|^cmd/|^pkg/|^internal/|^ui/|.*\.(sol|go|ts|tsx|js|jsx|py|rs|java|kt|cs|cpp|c)$' || true)"

# 2) 如果没有代码文件变更，直接放行
[ -z "$changed_files" ] && exit 0

# 3) 有代码变更但未同时暂存 AI_USAGE.md → 拒绝提交
if ! git diff --cached --name-only | grep -qx 'AI_USAGE.md'; then
  echo "❌ 检测到代码改动，但本次提交未更新 AI_USAGE.md。"
  echo "👉 请在 AI_USAGE.md 追加一行并运行：git add AI_USAGE.md"
  exit 1
fi

exit 0