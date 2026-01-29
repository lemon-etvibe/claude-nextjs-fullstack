# ============================================
# etvibe-nextjs-fullstack 셋업 스크립트 (Windows)
# ============================================
#
# 이 스크립트는 다음을 수행합니다:
# 1. 마켓플레이스 소스 등록
# 2. 외부 플러그인 설치
# 3. PowerShell 프로필에 claude-enf 함수 등록
#
# 사용법:
#   cd C:\plugins\enf
#   .\scripts\setup.ps1
#

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  etvibe-nextjs-fullstack 셋업" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: MCP 서버 (context7, next-devtools, prisma-local)는"
Write-Host "      플러그인 로드 시 자동으로 설정됩니다."
Write-Host ""

# ============================================
# 1. 마켓플레이스 추가
# ============================================

Write-Host "[1/4] 마켓플레이스 추가..." -ForegroundColor Yellow
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents
Write-Host "   vercel-labs/agent-skills" -ForegroundColor Green
Write-Host "   wshobson/agents" -ForegroundColor Green

# ============================================
# 2. Anthropic 공식 플러그인 설치
# ============================================

Write-Host ""
Write-Host "[2/4] Anthropic 공식 플러그인 설치..." -ForegroundColor Yellow
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory
Write-Host "   playwright (E2E 테스트)" -ForegroundColor Green
Write-Host "   pr-review-toolkit (/review-pr)" -ForegroundColor Green
Write-Host "   commit-commands (/commit)" -ForegroundColor Green
Write-Host "   feature-dev (기능 개발)" -ForegroundColor Green
Write-Host "   security-guidance (보안 검사)" -ForegroundColor Green

# ============================================
# 3. 커뮤니티 플러그인 설치
# ============================================

Write-Host ""
Write-Host "[3/4] 커뮤니티 플러그인 설치..." -ForegroundColor Yellow
claude plugin install react-best-practices@agent-skills
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
Write-Host "   react-best-practices (React 최적화)" -ForegroundColor Green
Write-Host "   javascript-typescript (JS/TS 전문가)" -ForegroundColor Green
Write-Host "   database-design (스키마 설계)" -ForegroundColor Green

# ============================================
# 4. PowerShell 프로필에 claude-enf 함수 등록
# ============================================

Write-Host ""
Write-Host "[4/4] PowerShell alias 등록..." -ForegroundColor Yellow

# 플러그인 경로 (스크립트 위치의 상위 디렉토리)
$pluginPath = Split-Path -Parent $PSScriptRoot

# claude-enf 함수 코드
$functionCode = @"

# claude-enf - etvibe-nextjs-fullstack 플러그인으로 Claude Code 실행
function claude-enf {
    claude --plugin-dir "$pluginPath" `$args
}
"@

# 프로필 파일이 없으면 생성
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    Write-Host "   PowerShell 프로필 생성: $PROFILE" -ForegroundColor Gray
}

# 이미 등록되어 있는지 확인
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -match "function claude-enf") {
    Write-Host "   claude-enf 함수가 이미 등록되어 있습니다." -ForegroundColor Gray
} else {
    Add-Content -Path $PROFILE -Value $functionCode
    Write-Host "   claude-enf 함수 등록 완료!" -ForegroundColor Green
}

# ============================================
# 완료
# ============================================

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  셋업 완료!" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "설치된 플러그인:" -ForegroundColor White
Write-Host ""
Write-Host "   [Anthropic 공식]" -ForegroundColor Gray
Write-Host "   - playwright (E2E 테스트)"
Write-Host "   - pr-review-toolkit (/review-pr)"
Write-Host "   - commit-commands (/commit)"
Write-Host "   - feature-dev (기능 개발)"
Write-Host "   - security-guidance (보안 검사)"
Write-Host ""
Write-Host "   [커뮤니티]" -ForegroundColor Gray
Write-Host "   - react-best-practices (React 최적화)"
Write-Host "   - javascript-typescript (JS/TS 전문가)"
Write-Host "   - database-design (스키마 설계)"
Write-Host ""
Write-Host "MCP 서버 (플러그인에서 자동 설정):" -ForegroundColor White
Write-Host "   - context7 (라이브러리 문서 조회)"
Write-Host "   - next-devtools (Next.js 개발 서버 연동)"
Write-Host "   - prisma-local (Prisma 마이그레이션/Studio)"
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "   1. 새 PowerShell 창을 열거나: . `$PROFILE"
Write-Host "   2. 프로젝트로 이동: cd C:\projects\your-project"
Write-Host "   3. Claude Code 실행: claude-enf"
Write-Host ""
