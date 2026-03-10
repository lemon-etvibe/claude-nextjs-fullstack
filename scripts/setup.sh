#!/bin/bash
# ============================================
# etvibe-nextjs-fullstack 셋업 스크립트 (macOS/Linux)
# ============================================
#
# 이 스크립트는 다음을 수행합니다:
# 1. 마켓플레이스 소스 등록
# 2. 외부 플러그인 설치
# 3. enf 플러그인 로컬 마켓플레이스 등록 및 설치
#
# 사용법:
#   cd ~/plugins/enf
#   chmod +x scripts/setup.sh
#   ./scripts/setup.sh                      # 인터랙티브 모드
#   ./scripts/setup.sh ~/projects/my-app    # 프로젝트 경로 직접 지정
#

# ============================================
# 프로젝트 경로 처리
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# 인자로 프로젝트 경로가 전달된 경우
if [ -n "$1" ]; then
    PROJECT_PATH=$(eval echo "$1")
# 플러그인 디렉토리에서 실행된 경우 → 경로 입력 받기
elif [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ] && [ "$PWD" = "$PLUGIN_DIR" ]; then
    echo ""
    echo "================================================"
    echo "  etvibe-nextjs-fullstack 셋업"
    echo "================================================"
    echo ""
    echo "📂 설치할 프로젝트 경로를 입력하세요 (Tab으로 자동완성):"
    read -e -p "> " PROJECT_PATH
    PROJECT_PATH=$(eval echo "$PROJECT_PATH")
fi

# 프로젝트 경로가 지정된 경우 이동
if [ -n "$PROJECT_PATH" ]; then
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 디렉토리가 존재하지 않습니다: $PROJECT_PATH"
        exit 1
    fi
    cd "$PROJECT_PATH"
    echo "✓ 프로젝트 경로: $PROJECT_PATH"
    echo ""
fi

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 에러 카운터
ERROR_COUNT=0
WARNING_COUNT=0

# ============================================
# 에러 핸들링 함수
# ============================================

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_skip() {
    echo -e "   ⏭️  $1"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================
# 사전 요구사항 확인
# ============================================

check_prerequisites() {
    echo ""
    echo "🔍 사전 요구사항 확인..."

    # 1. Claude CLI 확인
    if ! command -v claude &> /dev/null; then
        print_error "Claude Code가 설치되지 않았습니다."
        echo ""
        echo "   설치 방법:"
        echo "   npm install -g @anthropic-ai/claude-code"
        echo ""
        echo "   또는 공식 문서 참조:"
        echo "   https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    fi
    print_success "Claude Code 설치됨"

    # 2. Git 확인
    if ! command -v git &> /dev/null; then
        print_error "Git이 설치되지 않았습니다."
        exit 1
    fi
    print_success "Git 설치됨"

    # 3. 네트워크 연결 확인 (GitHub)
    if ! curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        print_warning "GitHub 연결 불가 - 외부 플러그인 설치가 실패할 수 있습니다."
        WARNING_COUNT=$((WARNING_COUNT + 1))
    else
        print_success "네트워크 연결 정상"
    fi

    echo ""
}

# ============================================
# 플러그인 설치 함수 (중복 설치 방지 + 에러 처리)
# ============================================

install_plugin() {
    local plugin="$1"
    local description="$2"
    local settings_file="$HOME/.claude/settings.json"

    # 설정 파일에서 이미 설치 여부 확인
    if [ -f "$settings_file" ] && grep -q "\"$plugin\"" "$settings_file"; then
        print_skip "$description (이미 설치됨)"
        return 0
    fi

    # 플러그인 설치 시도
    if claude plugin install "$plugin" 2>/dev/null; then
        print_success "$description"
        return 0
    else
        print_warning "$description 설치 실패 (나중에 수동 설치 가능)"
        echo "      claude plugin install $plugin"
        WARNING_COUNT=$((WARNING_COUNT + 1))
        return 0  # 실패해도 계속 진행
    fi
}

# ============================================
# 마켓플레이스 추가 함수 (중복 등록 방지 + 에러 처리)
# ============================================

add_marketplace() {
    local url="$1"
    local name="$2"

    # 이미 등록 여부 확인
    if claude plugin marketplace list 2>/dev/null | grep -q "$name"; then
        print_skip "$name (이미 등록됨)"
        return 0
    fi

    # 마켓플레이스 추가 시도
    if claude plugin marketplace add "$url" 2>/dev/null; then
        print_success "$name 추가 완료"
        return 0
    else
        # URL 유형에 따른 에러 메시지
        if [[ "$url" == https://github.com/* ]]; then
            print_warning "$name 등록 실패"
            echo "      가능한 원인:"
            echo "      - 저장소 접근 권한 없음 (private repo)"
            echo "      - GitHub rate limit 초과"
            echo "      - 네트워크 오류"
        else
            print_warning "$name 등록 실패"
        fi
        WARNING_COUNT=$((WARNING_COUNT + 1))
        return 1
    fi
}

# ============================================
# 메인 스크립트 시작
# ============================================

echo ""
echo "=============================================="
echo "  etvibe-nextjs-fullstack 셋업"
echo "=============================================="
echo ""
echo "Note: MCP 서버 (context7, next-devtools)는"
echo "      플러그인 로드 시 자동으로 설정됩니다."

# 사전 요구사항 확인
check_prerequisites

# ============================================
# 1. 마켓플레이스 등록 및 업데이트
# ============================================

echo "📦 [1/4] 마켓플레이스 등록..."

if add_marketplace "https://github.com/wshobson/agents" "claude-code-workflows"; then
    echo ""
    echo "   마켓플레이스 업데이트 중..."
    if claude plugin marketplace update 2>/dev/null; then
        print_success "마켓플레이스 업데이트 완료"
    else
        print_warning "마켓플레이스 업데이트 실패 (일부 플러그인 설치 불가)"
        WARNING_COUNT=$((WARNING_COUNT + 1))
    fi
else
    echo ""
    print_info "커뮤니티 플러그인은 나중에 수동으로 설치할 수 있습니다."
fi

# ============================================
# 2. Anthropic 공식 플러그인 설치
# ============================================

echo ""
echo "📦 [2/4] Anthropic 공식 플러그인 설치..."
install_plugin "playwright@claude-plugins-official" "playwright (E2E 테스트)"
install_plugin "pr-review-toolkit@claude-plugins-official" "pr-review-toolkit (/review-pr)"
install_plugin "commit-commands@claude-plugins-official" "commit-commands (/commit)"
install_plugin "feature-dev@claude-plugins-official" "feature-dev (기능 개발)"
install_plugin "security-guidance@claude-plugins-official" "security-guidance (보안 검사)"
install_plugin "context7@claude-plugins-official" "context7 (라이브러리 문서)"
install_plugin "frontend-design@claude-plugins-official" "frontend-design (UI 디자인)"
install_plugin "code-review@claude-plugins-official" "code-review (코드 리뷰)"

# ============================================
# 3. 커뮤니티 플러그인 설치
# ============================================

echo ""
echo "📦 [3/4] 커뮤니티 플러그인 설치..."
install_plugin "javascript-typescript@claude-code-workflows" "javascript-typescript (JS/TS 전문가)"
install_plugin "database-design@claude-code-workflows" "database-design (스키마 설계)"

# ============================================
# 4. 로컬 마켓플레이스 등록 및 enf 플러그인 설치
# ============================================

echo ""
echo "📦 [4/4] enf 플러그인 설치..."

# 플러그인 디렉토리 유효성 검사 (PLUGIN_DIR은 스크립트 시작 시 정의됨)
if [ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    print_error "플러그인 매니페스트를 찾을 수 없습니다: $PLUGIN_DIR/.claude-plugin/plugin.json"
    echo ""
    echo "   이 스크립트는 플러그인 루트 디렉토리의 scripts/ 폴더에서 실행해야 합니다."
    echo "   예: cd ~/plugins/enf && ./scripts/setup.sh"
    exit 1
fi

# 로컬 마켓플레이스 등록
add_marketplace "file://$PLUGIN_DIR" "enf-local"

# enf 플러그인 설치 (--scope local로 프로젝트별 설치)
# enabled 상태인지 확인 (다른 프로젝트에서 설치됐을 수 있음)
ENF_STATUS=$(claude plugin list 2>/dev/null | grep -A3 "enf@enf-local" || echo "")

if echo "$ENF_STATUS" | grep -q "Status: ✔ enabled"; then
    print_skip "enf 플러그인 (이미 활성화됨)"
elif echo "$ENF_STATUS" | grep -q "enf@enf-local"; then
    # 설치됐지만 현재 프로젝트에서 disabled 상태 → enable
    echo "   현재 프로젝트에서 활성화 중..."
    if claude plugin enable enf@enf-local --scope local 2>/dev/null; then
        print_success "enf 플러그인 활성화 완료"
    else
        print_error "enf 플러그인 활성화 실패"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
else
    # 미설치 → 새로 설치
    if claude plugin install enf@enf-local --scope local 2>/dev/null; then
        print_success "enf 플러그인 설치 완료"
    else
        print_error "enf 플러그인 설치 실패"
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo ""
        echo "   문제 해결:"
        echo "   1. 플러그인 검증: claude plugin validate $PLUGIN_DIR"
        echo "   2. 수동 설치: claude plugin install enf@enf-local --scope local"
    fi
fi

# ============================================
# 완료 메시지
# ============================================

echo ""
echo "=============================================="

if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}셋업 완료!${NC}"
elif [ $ERROR_COUNT -eq 0 ]; then
    echo -e "  ${YELLOW}셋업 완료 (경고 ${WARNING_COUNT}개)${NC}"
else
    echo -e "  ${RED}셋업 완료 (에러 ${ERROR_COUNT}개, 경고 ${WARNING_COUNT}개)${NC}"
fi

echo "=============================================="
echo ""
echo "📋 설치된 플러그인:"
echo ""
echo "   [Anthropic 공식]"
echo "   - playwright (E2E 테스트)"
echo "   - pr-review-toolkit (/review-pr)"
echo "   - commit-commands (/commit)"
echo "   - feature-dev (기능 개발)"
echo "   - security-guidance (보안 검사)"
echo "   - context7 (라이브러리 문서)"
echo "   - frontend-design (UI 디자인)"
echo "   - code-review (코드 리뷰)"
echo ""
echo "   [커뮤니티 - wshobson/agents]"
echo "   - javascript-typescript (JS/TS 전문가)"
echo "   - database-design (스키마 설계)"
echo ""
echo "   [로컬 플러그인]"
echo "   - enf (etvibe-nextjs-fullstack)"
echo ""
echo "📋 MCP 서버 (플러그인에서 자동 설정):"
echo "   - context7 (라이브러리 문서 조회)"
echo "   - next-devtools (Next.js 개발 서버 연동)"
echo ""
echo "📋 선택 플러그인 (수동 설치):"
echo "   npx @anthropic-ai/claude-code add-skill react-best-practices"
echo ""

if [ $WARNING_COUNT -gt 0 ]; then
    echo "⚠️  일부 플러그인 설치에 실패했습니다."
    echo "   실패한 플러그인은 위의 명령어로 나중에 수동 설치할 수 있습니다."
    echo ""
fi

echo "🚀 다음 단계:"
echo "   1. 프로젝트로 이동: cd ~/projects/your-project"
echo "   2. Claude Code 실행: claude"
echo ""
