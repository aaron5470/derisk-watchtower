# PowerShell version of require_ai_usage_simple.sh for Windows compatibility
$ErrorActionPreference = "Stop"

# Get staged code files
$stagedFiles = git diff --cached --name-only --diff-filter=ACMR
$codeFiles = $stagedFiles | Where-Object { 
    $_ -match '^(contracts/|backend/|frontend/|api/|cmd/|pkg/|internal/|ui/)' -or
    $_ -match '\.(sol|go|ts|tsx|js|jsx|py|rs|java|kt|cs|cpp|c)$'
}

# If no code files changed, allow commit
if (-not $codeFiles) {
    exit 0
}

# Check if AI_USAGE.md is staged
$aiUsageStaged = $stagedFiles | Where-Object { $_ -eq 'AI_USAGE.md' }
if (-not $aiUsageStaged) {
    Write-Host "Error: Code changes detected but AI_USAGE.md not updated" -ForegroundColor Red
    Write-Host "Please add a line to AI_USAGE.md and run: git add AI_USAGE.md" -ForegroundColor Yellow
    exit 1
}

exit 0