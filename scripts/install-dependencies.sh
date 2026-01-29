#!/bin/bash
set -e

echo "=============================================="
echo "  etvibe-nextjs-fullstack 외부 의존성 설치"
echo "=============================================="
echo ""

# ============================================
# 필수 설치
# ============================================

echo "📦 [1/6] MCP 서버 추가..."
echo "   - context7 (라이브러리 문서 조회)"
claude mcp add context7 -- npx -y @anthropic-ai/context7-mcp@latest
echo "   - next-devtools (Next.js 개발 서버 연동)"
claude mcp add next-devtools -- npx -y @anthropic-ai/next-devtools-mcp@latest
echo "   - prisma-local (마이그레이션/Studio)"
claude mcp add prisma-local -- npx prisma mcp

echo ""
echo "📦 [2/6] 마켓플레이스 추가..."
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents

echo ""
echo "📦 [3/6] Anthropic 공식 플러그인 설치..."
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory

echo ""
echo "📦 [4/6] Vercel Labs 스킬 설치..."
npx skills add vercel-labs/next-skills
claude plugin install react-best-practices@agent-skills

echo ""
echo "📦 [5/6] wshobson 플러그인 설치..."
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents

echo ""
echo "📦 [6/6] 설치 확인..."
echo ""
echo "✅ 필수 설치 완료!"
echo ""
echo "📋 설치된 외부 의존성 (필수):"
echo "   [MCP 서버]"
echo "   - context7 (라이브러리 문서 조회)"
echo "   - next-devtools (Next.js 개발 서버 연동)"
echo "   - Prisma MCP (마이그레이션/Studio)"
echo ""
echo "   [플러그인/스킬]"
echo "   - Playwright (E2E 테스트)"
echo "   - pr-review-toolkit (PR 리뷰)"
echo "   - commit-commands (Git 워크플로우)"
echo "   - feature-dev (기능 개발)"
echo "   - security-guidance (보안 경고)"
echo "   - react-best-practices (React 최적화)"
echo "   - next-best-practices (Next.js 지식)"
echo "   - javascript-typescript (JS/TS 전문가)"
echo "   - database-design (스키마 설계)"
echo ""

# ============================================
# 옵셔널 설치
# ============================================

echo "=============================================="
echo "  옵셔널 플러그인 설치"
echo "=============================================="
echo ""
echo "다음 옵셔널 플러그인을 설치하시겠습니까?"
echo ""
echo "  1) frontend-design       - 고품질 프론트엔드 UI 디자인 (Anthropic 공식)"
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
    echo "✅ frontend-design 설치 완료!"
    ;;
  2)
    echo ""
    echo "📦 web-design-guidelines 설치 중..."
    claude plugin install web-design-guidelines@agent-skills
    echo "✅ web-design-guidelines 설치 완료!"
    ;;
  3)
    echo ""
    echo "📦 frontend-design 설치 중..."
    claude plugin install frontend-design@claude-plugin-directory
    echo "📦 web-design-guidelines 설치 중..."
    claude plugin install web-design-guidelines@agent-skills
    echo "✅ 옵셔널 플러그인 모두 설치 완료!"
    ;;
  4)
    echo ""
    echo "⏭️  옵셔널 플러그인 설치를 건너뜁니다."
    ;;
  *)
    echo ""
    echo "⏭️  잘못된 선택입니다. 옵셔널 플러그인 설치를 건너뜁니다."
    ;;
esac

echo ""
echo "=============================================="
echo "  etvibe-nextjs-fullstack 설치 완료!"
echo "=============================================="
echo ""
echo "📚 다음 단계:"
echo "   1. 프로젝트 디렉토리에서 Claude Code 실행"
echo "   2. /review-pr, /commit 등 스킬 사용 가능"
echo "   3. 자세한 사용법은 README.md 참조"
echo ""
