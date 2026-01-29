# ============================================
# etvibe-nextjs-fullstack 셋업 스크립트 (Windows)
# ============================================
#
# 이 스크립트는 다음을 수행합니다:
# 1. 마켓플레이스 소스 등록
# 2. 외부 플러그인 설치
# 3. enf 플러그인 로컬 마켓플레이스 등록 및 설치
#
# 사용법:
#   cd C:\plugins\enf
#   .\scripts\setup.ps1                        # 인터랙티브 모드
#   .\scripts\setup.ps1 C:\projects\my-app     # 프로젝트 경로 직접 지정
#

# ============================================
# 프로젝트 경로 처리
# ============================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PluginDir = Split-Path -Parent $ScriptDir

# 인자로 프로젝트 경로가 전달된 경우
if ($args.Count -gt 0) {
    $ProjectPath = $args[0]
}
# 플러그인 디렉토리에서 실행된 경우 → 경로 입력 받기
elseif ((Test-Path "$PluginDir\.claude-plugin\plugin.json") -and ($PWD.Path -eq $PluginDir)) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  etvibe-nextjs-fullstack Setup" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    $ProjectPath = Read-Host "Install target project path"
}

# 프로젝트 경로가 지정된 경우 이동
if ($ProjectPath) {
    # ~ 를 홈 디렉토리로 확장
    if ($ProjectPath.StartsWith("~")) {
        $ProjectPath = $ProjectPath.Replace("~", $env:USERPROFILE)
    }
    # 환경 변수 확장
    $ProjectPath = [Environment]::ExpandEnvironmentVariables($ProjectPath)

    if (-not (Test-Path $ProjectPath)) {
        Write-Host "X Directory does not exist: $ProjectPath" -ForegroundColor Red
        exit 1
    }
    Set-Location $ProjectPath
    Write-Host "v Project path: $ProjectPath" -ForegroundColor Green
    Write-Host ""
}

# 에러 카운터
$script:ErrorCount = 0
$script:WarningCount = 0

# ============================================
# 출력 함수
# ============================================

function Write-Error-Message {
    param([string]$Message)
    Write-Host "X $Message" -ForegroundColor Red
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "! $Message" -ForegroundColor Yellow
}

function Write-Success-Message {
    param([string]$Message)
    Write-Host "  v $Message" -ForegroundColor Green
}

function Write-Skip-Message {
    param([string]$Message)
    Write-Host "   (skip) $Message" -ForegroundColor Gray
}

function Write-Info-Message {
    param([string]$Message)
    Write-Host "  i $Message" -ForegroundColor Cyan
}

# ============================================
# 사전 요구사항 확인
# ============================================

function Test-Prerequisites {
    Write-Host ""
    Write-Host "Checking prerequisites..." -ForegroundColor White

    # 1. Claude CLI 확인
    $claudeCommand = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claudeCommand) {
        Write-Error-Message "Claude Code is not installed."
        Write-Host ""
        Write-Host "   Installation:"
        Write-Host "   npm install -g @anthropic-ai/claude-code"
        Write-Host ""
        Write-Host "   Or see official docs:"
        Write-Host "   https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    }
    Write-Success-Message "Claude Code installed"

    # 2. Git 확인
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitCommand) {
        Write-Error-Message "Git is not installed."
        exit 1
    }
    Write-Success-Message "Git installed"

    # 3. 네트워크 연결 확인 (GitHub)
    try {
        $response = Invoke-WebRequest -Uri "https://github.com" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Success-Message "Network connection OK"
    } catch {
        Write-Warning-Message "Cannot connect to GitHub - some plugins may fail to install."
        $script:WarningCount++
    }

    Write-Host ""
}

# ============================================
# 플러그인 설치 함수 (중복 설치 방지 + 에러 처리)
# ============================================

function Install-PluginIfNeeded {
    param(
        [string]$Plugin,
        [string]$Description
    )

    $settingsFile = "$env:USERPROFILE\.claude\settings.json"
    $isInstalled = $false

    if (Test-Path $settingsFile) {
        $content = Get-Content $settingsFile -Raw -ErrorAction SilentlyContinue
        if ($content -match [regex]::Escape($Plugin)) {
            $isInstalled = $true
        }
    }

    if ($isInstalled) {
        Write-Skip-Message "$Description (already installed)"
        return
    }

    # 플러그인 설치 시도
    $result = claude plugin install $Plugin 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success-Message "$Description"
    } else {
        Write-Warning-Message "$Description install failed (can install manually later)"
        Write-Host "      claude plugin install $Plugin" -ForegroundColor Gray
        $script:WarningCount++
    }
}

# ============================================
# 마켓플레이스 추가 함수 (중복 등록 방지 + 에러 처리)
# ============================================

function Add-MarketplaceIfNeeded {
    param(
        [string]$Url,
        [string]$Name
    )

    $marketplaceList = claude plugin marketplace list 2>&1
    if ($marketplaceList -match $Name) {
        Write-Skip-Message "$Name (already registered)"
        return $true
    }

    # 마켓플레이스 추가 시도
    $result = claude plugin marketplace add $Url 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success-Message "$Name added"
        return $true
    } else {
        # URL 유형에 따른 에러 메시지
        if ($Url -match "^https://github.com/") {
            Write-Warning-Message "$Name registration failed"
            Write-Host "      Possible causes:" -ForegroundColor Gray
            Write-Host "      - No access to repository (private repo)" -ForegroundColor Gray
            Write-Host "      - GitHub rate limit exceeded" -ForegroundColor Gray
            Write-Host "      - Network error" -ForegroundColor Gray
        } else {
            Write-Warning-Message "$Name registration failed"
        }
        $script:WarningCount++
        return $false
    }
}

# ============================================
# 메인 스크립트 시작
# ============================================

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  etvibe-nextjs-fullstack Setup" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: MCP servers (context7, next-devtools, prisma-local)"
Write-Host "      are automatically configured when the plugin loads."
Write-Host ""

# 사전 요구사항 확인
Test-Prerequisites

# ============================================
# 1. 마켓플레이스 등록 및 업데이트
# ============================================

Write-Host "[1/4] Registering marketplace..." -ForegroundColor Yellow

$marketplaceAdded = Add-MarketplaceIfNeeded "https://github.com/wshobson/agents" "claude-code-workflows"

if ($marketplaceAdded) {
    Write-Host ""
    Write-Host "   Updating marketplace..." -ForegroundColor Gray
    $updateResult = claude plugin marketplace update 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success-Message "Marketplace updated"
    } else {
        Write-Warning-Message "Marketplace update failed (some plugins may not install)"
        $script:WarningCount++
    }
} else {
    Write-Host ""
    Write-Info-Message "Community plugins can be installed manually later."
}

# ============================================
# 2. Anthropic 공식 플러그인 설치
# ============================================

Write-Host ""
Write-Host "[2/4] Installing Anthropic official plugins..." -ForegroundColor Yellow
Install-PluginIfNeeded "playwright@claude-plugins-official" "playwright (E2E testing)"
Install-PluginIfNeeded "pr-review-toolkit@claude-plugins-official" "pr-review-toolkit (/review-pr)"
Install-PluginIfNeeded "commit-commands@claude-plugins-official" "commit-commands (/commit)"
Install-PluginIfNeeded "feature-dev@claude-plugins-official" "feature-dev (feature development)"
Install-PluginIfNeeded "security-guidance@claude-plugins-official" "security-guidance (security check)"
Install-PluginIfNeeded "context7@claude-plugins-official" "context7 (library docs)"
Install-PluginIfNeeded "frontend-design@claude-plugins-official" "frontend-design (UI design)"
Install-PluginIfNeeded "code-review@claude-plugins-official" "code-review (code review)"

# ============================================
# 3. 커뮤니티 플러그인 설치
# ============================================

Write-Host ""
Write-Host "[3/4] Installing community plugins..." -ForegroundColor Yellow
Install-PluginIfNeeded "javascript-typescript@claude-code-workflows" "javascript-typescript (JS/TS expert)"
Install-PluginIfNeeded "database-design@claude-code-workflows" "database-design (schema design)"

# ============================================
# 4. 로컬 마켓플레이스 등록 및 enf 플러그인 설치
# ============================================

Write-Host ""
Write-Host "[4/4] Installing enf plugin..." -ForegroundColor Yellow

# 플러그인 디렉토리 유효성 검사 ($PluginDir은 스크립트 시작 시 정의됨)
$manifestPath = Join-Path $PluginDir ".claude-plugin\plugin.json"
if (-not (Test-Path $manifestPath)) {
    Write-Error-Message "Plugin manifest not found: $manifestPath"
    Write-Host ""
    Write-Host "   This script must be run from the scripts/ folder in the plugin root."
    Write-Host "   Example: cd C:\plugins\enf; .\scripts\setup.ps1"
    exit 1
}

# 로컬 마켓플레이스 등록
Add-MarketplaceIfNeeded "file://$PluginDir" "enf-local"

# enf 플러그인 설치 (--scope local로 프로젝트 독립 설치)
$pluginList = claude plugin list 2>&1
if ($pluginList -match "enf@enf-local") {
    Write-Skip-Message "enf plugin (already installed)"
} else {
    $installResult = claude plugin install enf@enf-local --scope local 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success-Message "enf plugin installed"
    } else {
        Write-Error-Message "enf plugin installation failed"
        $script:ErrorCount++
        Write-Host ""
        Write-Host "   Troubleshooting:"
        Write-Host "   1. Validate plugin: claude plugin validate $PluginDir"
        Write-Host "   2. Manual install: claude plugin install enf@enf-local --scope local"
    }
}

# ============================================
# 완료 메시지
# ============================================

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan

if ($script:ErrorCount -eq 0 -and $script:WarningCount -eq 0) {
    Write-Host "  Setup Complete!" -ForegroundColor Green
} elseif ($script:ErrorCount -eq 0) {
    Write-Host "  Setup Complete (warnings: $($script:WarningCount))" -ForegroundColor Yellow
} else {
    Write-Host "  Setup Complete (errors: $($script:ErrorCount), warnings: $($script:WarningCount))" -ForegroundColor Red
}

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed plugins:" -ForegroundColor White
Write-Host ""
Write-Host "   [Anthropic Official]" -ForegroundColor Gray
Write-Host "   - playwright (E2E testing)"
Write-Host "   - pr-review-toolkit (/review-pr)"
Write-Host "   - commit-commands (/commit)"
Write-Host "   - feature-dev (feature development)"
Write-Host "   - security-guidance (security check)"
Write-Host "   - context7 (library docs)"
Write-Host "   - frontend-design (UI design)"
Write-Host "   - code-review (code review)"
Write-Host ""
Write-Host "   [Community - wshobson/agents]" -ForegroundColor Gray
Write-Host "   - javascript-typescript (JS/TS expert)"
Write-Host "   - database-design (schema design)"
Write-Host ""
Write-Host "   [Local Plugin]" -ForegroundColor Gray
Write-Host "   - enf (etvibe-nextjs-fullstack)"
Write-Host ""
Write-Host "MCP Servers (auto-configured by plugin):" -ForegroundColor White
Write-Host "   - context7 (library docs lookup)"
Write-Host "   - next-devtools (Next.js dev server)"
Write-Host "   - prisma-local (Prisma migrations/Studio)"
Write-Host ""
Write-Host "Optional plugin (manual install):" -ForegroundColor White
Write-Host "   npx @anthropic-ai/claude-code add-skill react-best-practices"
Write-Host ""

if ($script:WarningCount -gt 0) {
    Write-Host "! Some plugins failed to install." -ForegroundColor Yellow
    Write-Host "   You can install them manually later using the commands shown above."
    Write-Host ""
}

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "   1. Go to your project: cd C:\projects\your-project"
Write-Host "   2. Run Claude Code: claude"
Write-Host ""
