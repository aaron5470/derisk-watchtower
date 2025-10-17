# Install Git hooks for AI_USAGE.md compliance
Write-Host "Installing Git hooks for AI_USAGE.md compliance..." -ForegroundColor Green

$hookPath = ".git/hooks/pre-commit"
$psHookPath = ".git/hooks/pre-commit.ps1"

# Check if hooks already exist
if (Test-Path $hookPath) {
    Write-Host "Git pre-commit hook already exists!" -ForegroundColor Yellow
} else {
    Write-Host "Git hooks not found. Please run this script from the project root directory." -ForegroundColor Red
    exit 1
}

# Make the hook executable (if on Unix-like system)
if (Get-Command "chmod" -ErrorAction SilentlyContinue) {
    chmod +x $hookPath
    Write-Host "Made pre-commit hook executable" -ForegroundColor Green
}

# Test the hook
Write-Host "Testing the hook..." -ForegroundColor Blue
try {
    & powershell -ExecutionPolicy Bypass -File $psHookPath
    Write-Host "Hook test passed!" -ForegroundColor Green
} catch {
    Write-Host "Hook test failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Git hooks installed successfully!" -ForegroundColor Green
Write-Host "The hook will now check that AI_USAGE.md is updated when code changes are committed." -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage example:" -ForegroundColor Yellow
Write-Host "1. Make code changes: git add backend/main.go" -ForegroundColor White
Write-Host "2. Update AI_USAGE.md: echo '2025-01-16 | Claude | backend/main.go | owner=ai review=none | Added feature' >> AI_USAGE.md" -ForegroundColor White
Write-Host "3. Stage AI_USAGE.md: git add AI_USAGE.md" -ForegroundColor White
Write-Host "4. Commit: git commit -m 'feat: add new feature'" -ForegroundColor White