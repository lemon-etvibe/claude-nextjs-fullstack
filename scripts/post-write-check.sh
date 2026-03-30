#!/bin/bash
# 통합 PostToolUse 검사 스크립트
# Write/Edit 후 파일 패턴에 따라 적절한 검사 수행
# Hook: PostToolUse (Write|Edit)

FILE="$1"

# ─────────────────────────────────────────
# 인자 검증
# ─────────────────────────────────────────
if [[ -z "$FILE" ]]; then
  exit 0
fi

# ─────────────────────────────────────────
# .env 파일 커밋 방어 (exit 2: 작업 중단)
# ─────────────────────────────────────────
BASENAME=$(basename "$FILE")
if [[ "$BASENAME" =~ ^\.env ]]; then
  echo ""
  echo "!! 오류: 환경 변수 파일이 수정되었습니다: $FILE"
  echo ""
  echo "  .env 파일은 절대 커밋하지 마세요!"
  echo "  - .gitignore에 .env* 패턴이 포함되어 있는지 확인하세요"
  echo "  - 비밀 값은 환경 변수 또는 시크릿 매니저를 사용하세요"
  echo "  - 필요 시 .env.example에 키 이름만 기록하세요 (값 제외)"
  echo ""
  exit 2
fi

# ─────────────────────────────────────────
# 관련 없는 파일은 즉시 종료 (early return)
# ─────────────────────────────────────────
if [[ ! "$FILE" =~ \.(ts|tsx)$ ]]; then
  exit 0
fi

# ─────────────────────────────────────────
# Drizzle 스키마 검사 (src/db/schema.ts)
# ─────────────────────────────────────────
if [[ "$FILE" =~ db/schema\.ts$ ]]; then
  echo ""
  echo "Drizzle 스키마가 수정되었습니다: $FILE"
  echo ""
  echo "다음 단계를 수행하세요:"
  echo ""
  echo "  1. 마이그레이션 파일 생성:"
  echo "     npx drizzle-kit generate"
  echo ""
  echo "  2. 개발 환경에 적용:"
  echo "     npx drizzle-kit migrate"
  echo ""
  echo "  3. (빠른 프로토타이핑) 마이그레이션 없이 직접 적용:"
  echo "     npx drizzle-kit push"
  echo ""
  echo "또는 /schema-design 명령어로 스키마 설계 검토를 받으세요."
  exit 0
fi

# ─────────────────────────────────────────
# lucide-react barrel import 감지
# ─────────────────────────────────────────
if grep -q "from \"lucide-react\"" "$FILE" 2>/dev/null || grep -q "from 'lucide-react'" "$FILE" 2>/dev/null; then
  echo ""
  echo "lucide-react barrel import가 감지되었습니다: $FILE"
  echo ""
  echo "  번들 사이즈 최적화를 위해 개별 import를 권장합니다:"
  echo "    import { Search } from 'lucide-react'       # ❌ barrel import"
  echo "    import { Search } from 'lucide-react/search' # ✅ 개별 import"
  echo ""
fi

# ─────────────────────────────────────────
# console.log 감지 (테스트 파일 제외)
# ─────────────────────────────────────────
if [[ ! "$FILE" =~ \.test\.(ts|tsx)$ ]] && [[ ! "$FILE" =~ __tests__/ ]]; then
  if grep -q "console\.log" "$FILE" 2>/dev/null; then
    echo ""
    echo "console.log가 감지되었습니다: $FILE"
    echo "  프로덕션 코드에서는 console.log를 제거하세요."
    echo "  디버깅용이라면 console.error 또는 로깅 유틸리티를 사용하세요."
    echo ""
  fi
fi

# ─────────────────────────────────────────
# page.tsx + route.ts 같은 폴더 충돌 감지
# ─────────────────────────────────────────
DIR=$(dirname "$FILE")
if [[ "$BASENAME" =~ ^(page|route)\.(ts|tsx)$ ]]; then
  if [[ -f "$DIR/page.tsx" || -f "$DIR/page.ts" ]] && [[ -f "$DIR/route.tsx" || -f "$DIR/route.ts" ]]; then
    echo ""
    echo "⚠️ Next.js 충돌: page와 route가 같은 폴더에 있습니다: $DIR"
    echo "  page.tsx와 route.ts는 같은 라우트 세그먼트에 공존할 수 없습니다."
    echo "  하나를 제거하거나 다른 폴더로 이동하세요."
    echo ""
  fi
fi

# ─────────────────────────────────────────
# TypeScript 파일 공통 안내
# ─────────────────────────────────────────
echo ""
echo "TypeScript 파일이 수정되었습니다: $FILE"
echo ""
echo "권장 검사:"
echo "  1. pnpm tsc --noEmit     # 타입 검사"
echo "  2. pnpm lint             # ESLint 검사"
echo ""
echo "또는 /type-check 명령어를 사용하세요."

# ─────────────────────────────────────────
# Server Action 추가 검사
# ─────────────────────────────────────────
if [[ "$FILE" =~ _actions/.*\.ts$ ]]; then
  echo ""
  echo "Server Action 파일이 수정되었습니다: $FILE"
  echo ""

  if ! grep -q "use server" "$FILE" 2>/dev/null; then
    echo "  'use server' 지시문이 없습니다!"
  fi

  if ! grep -qE "auth.api.getSession|requireAuth|requireAdmin|requireCustomer" "$FILE" 2>/dev/null; then
    echo "  인증 검사가 없습니다. Better Auth 세션 검증을 권장합니다."
    echo ""
    echo "  권장 패턴:"
    echo "    const session = await auth.api.getSession({ headers: await headers() })"
    echo "    if (!session) return { error: '인증이 필요합니다.' }"
    echo ""
    echo "  또는 유틸리티 함수 사용:"
    echo "    const session = await requireAuth()  // src/lib/auth-utils.ts"
  fi

  if ! grep -q "revalidatePath\|revalidateTag" "$FILE" 2>/dev/null; then
    echo ""
    echo "  캐시 무효화가 없습니다. 데이터 변경 시 revalidatePath()를 권장합니다."
  fi

  echo ""
fi

exit 0
