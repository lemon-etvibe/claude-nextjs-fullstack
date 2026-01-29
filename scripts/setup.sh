#!/bin/bash
# ============================================
# etvibe-nextjs-fullstack 셋업 스크립트 (macOS/Linux)
# ============================================
#
# 이 스크립트는 다음을 수행합니다:
# 1. 마켓플레이스 소스 등록
# 2. 외부 플러그인 설치
# 3. Shell 프로필에 claude-enf alias 등록
#
# 사용법:
#   cd ~/plugins/enf
#   chmod +x scripts/setup.sh
#   ./scripts/setup.sh
#

set -e

echo ""
echo "=============================================="
echo "  etvibe-nextjs-fullstack 셋업"
echo "=============================================="
echo ""
echo "Note: MCP 서버 (context7, next-devtools, prisma-local)는"
echo "      플러그인 로드 시 자동으로 설정됩니다."
echo ""

# ============================================
# 1. 마켓플레이스 추가
# ============================================

echo "📦 [1/4] 마켓플레이스 추가..."
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents
echo "   ✓ vercel-labs/agent-skills"
echo "   ✓ wshobson/agents"

# ============================================
# 2. Anthropic 공식 플러그인 설치
# ============================================

echo ""
echo "📦 [2/4] Anthropic 공식 플러그인 설치..."
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory
echo "   ✓ playwright (E2E 테스트)"
echo "   ✓ pr-review-toolkit (/review-pr)"
echo "   ✓ commit-commands (/commit)"
echo "   ✓ feature-dev (기능 개발)"
echo "   ✓ security-guidance (보안 검사)"

# ============================================
# 3. 커뮤니티 플러그인 설치
# ============================================

echo ""
echo "📦 [3/4] 커뮤니티 플러그인 설치..."
claude plugin install react-best-practices@agent-skills
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
echo "   ✓ react-best-practices (React 최적화)"
echo "   ✓ javascript-typescript (JS/TS 전문가)"
echo "   ✓ database-design (스키마 설계)"

# ============================================
# 4. Shell 프로필에 claude-enf alias 등록
# ============================================

echo ""
echo "📦 [4/4] Shell alias 등록..."

# 플러그인 경로 (스크립트 위치의 상위 디렉토리)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# Shell 프로필 파일 결정
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# alias 코드
ALIAS_CODE="
# claude-enf - etvibe-nextjs-fullstack 플러그인으로 Claude Code 실행
alias claude-enf='claude --plugin-dir $PLUGIN_DIR'"

# 이미 등록되어 있는지 확인
if grep -q "alias claude-enf=" "$SHELL_RC" 2>/dev/null; then
    echo "   ⚠️  claude-enf alias가 이미 등록되어 있습니다."
else
    echo "$ALIAS_CODE" >> "$SHELL_RC"
    echo "   ✓ claude-enf alias 등록 완료! ($SHELL_RC)"
fi

# ============================================
# 완료
# ============================================

echo ""
echo "=============================================="
echo "  셋업 완료!"
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
echo ""
echo "   [커뮤니티]"
echo "   - react-best-practices (React 최적화)"
echo "   - javascript-typescript (JS/TS 전문가)"
echo "   - database-design (스키마 설계)"
echo ""
echo "📋 MCP 서버 (플러그인에서 자동 설정):"
echo "   - context7 (라이브러리 문서 조회)"
echo "   - next-devtools (Next.js 개발 서버 연동)"
echo "   - prisma-local (Prisma 마이그레이션/Studio)"
echo ""
echo "🚀 다음 단계:"
echo "   1. 새 터미널을 열거나: source $SHELL_RC"
echo "   2. 프로젝트로 이동: cd ~/projects/your-project"
echo "   3. Claude Code 실행: claude-enf"
echo ""
