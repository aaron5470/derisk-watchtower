# AI_USAGE.md 合规检查钩子

## 概述

这个pre-commit钩子确保当代码发生变更时，开发者必须同时更新 `AI_USAGE.md` 文件。

## 工作原理

钩子会检查：
1. 是否有代码文件被暂存（staged）
2. 如果有代码变更，是否同时暂存了 `AI_USAGE.md`
3. 如果没有更新 `AI_USAGE.md`，则拒绝提交

## 检查的文件类型

- 目录：`contracts/`, `backend/`, `frontend/`, `api/`, `cmd/`, `pkg/`, `internal/`, `ui/`
- 扩展名：`.sol`, `.go`, `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.rs`, `.java`, `.kt`, `.cs`, `.cpp`, `.c`

## 安装方法

### 方法1：使用原生 Git 钩子（推荐，无需额外依赖）

```powershell
# 运行安装脚本
powershell -ExecutionPolicy Bypass -File scripts/install-git-hooks.ps1
```

### 方法2：使用 pre-commit 工具（需要 Python 环境）

```bash
# 1. 安装 pre-commit
pip install pre-commit

# 2. 安装钩子到项目
pre-commit install

# 3. 手动运行测试（可选）
pre-commit run --all-files
```

## 使用示例

### 正确的工作流程

```bash
# 1. 修改代码文件
git add backend/main.go

# 2. 更新 AI_USAGE.md
echo "2025-01-16 | Claude | backend/main.go | owner=ai review=none | Added new feature" >> AI_USAGE.md

# 3. 暂存 AI_USAGE.md
git add AI_USAGE.md

# 4. 提交（钩子会通过）
git commit -m "feat: add new feature"
```

### 错误的工作流程

```bash
# 1. 修改代码文件
git add backend/main.go

# 2. 直接提交（没有更新 AI_USAGE.md）
git commit -m "feat: add new feature"
# ❌ 钩子会拒绝提交并显示错误信息
```

## 跳过钩子（紧急情况）

如果在紧急情况下需要跳过钩子：

```bash
git commit --no-verify -m "emergency fix"
```

**注意：** 请谨慎使用 `--no-verify`，并在事后补充 `AI_USAGE.md` 记录。

## 文件说明

- `scripts/require_ai_usage_simple.sh` - Linux/macOS 版本的检查脚本
- `scripts/require_ai_usage_simple.ps1` - Windows PowerShell 版本的检查脚本
- `.pre-commit-config.yaml` - pre-commit 配置文件，包含两个版本的钩子