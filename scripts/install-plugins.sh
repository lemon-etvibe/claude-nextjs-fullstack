#!/bin/bash
set -e

echo "=============================================="
echo "  etvibe-nextjs-fullstack 외부 플러그인 설치"
echo "=============================================="
echo ""
echo "Note: MCP 서버 (context7, next-devtools, prisma-local)는"
echo "      플러그인 설치 시 자동으로 설정됩니다."
echo ""

# ============================================
# 마켓플레이스 추가
# ============================================

echo "📦 [1/4] 마켓플레이스 추가..."
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents
echo "   ✓ vercel-labs/agent-skills"
echo "   ✓ wshobson/agents"

# ============================================
# 필수 플러그인 설치
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

echo ""
echo "📦 [3/4] 커뮤니티 플러그인 설치..."
claude plugin install react-best-practices@agent-skills
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
echo "   ✓ react-best-practices (React 최적화)"
echo "   ✓ javascript-typescript (JS/TS 전문가)"
echo "   ✓ database-design (스키마 설계)"

# ============================================
# 옵셔널 설치
# ============================================

echo ""
echo "=============================================="
echo "  옵셔널 플러그인 설치"
echo "=============================================="
echo ""
echo "다음 옵셔널 플러그인을 설치하시겠습니까?"
echo ""
echo "  1) frontend-design       - 고품질 프론트엔드 UI 디자인 (Anthropic)"
echo "  2) web-design-guidelines - 접근성/UX 감사 100+ 규칙 (Vercel Labs)"
echo "  3) 둘 다 설치"
echo "  4) 건너뛰기"
echo ""

read -p "선택 (1/2/3/4): " optional_choice

case $optional_choice in
  1)
    echo ""
    echo "📦 frontend-design 설치 중..."
    claude plugin install frontend-design@claude-plugin-directory
    echo "   ✓ frontend-design 설치 완료!"
    ;;
  2)
    echo ""
    echo "📦 web-design-guidelines 설치 중..."
    claude plugin install web-design-guidelines@agent-skills
    echo "   ✓ web-design-guidelines 설치 완료!"
    ;;
  3)
    echo ""
    echo "📦 frontend-design 설치 중..."
    claude plugin install frontend-design@claude-plugin-directory
    echo "📦 web-design-guidelines 설치 중..."
    claude plugin install web-design-guidelines@agent-skills
    echo "   ✓ 옵셔널 플러그인 모두 설치 완료!"
    ;;
  4)
    echo ""
    echo "⏭️  옵셔널 플러그인 설치를 건너뜁니다."
    ;;
  *)
    echo ""
    echo "⏭️  옵셔널 플러그인 설치를 건너뜁니다."
    ;;
esac

# ============================================
# 완료
# ============================================

echo ""
echo "=============================================="
echo "  설치 완료!"
echo "=============================================="
echo ""
echo "📋 설치된 외부 플러그인:"
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
