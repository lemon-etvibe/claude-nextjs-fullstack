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
if [[ ! "$FILE" =~ \.(ts|tsx)$ ]] && [[ ! "$FILE" =~ schema\.prisma$ ]]; then
  exit 0
fi

# ─────────────────────────────────────────
# Prisma 스키마 검사
# ─────────────────────────────────────────
if [[ "$FILE" =~ schema\.prisma$ ]]; then
  echo ""
  echo "Prisma 스키마가 수정되었습니다: $FILE"
  echo ""
  echo "다음 단계를 수행하세요:"
  echo ""
  echo "  1. 스키마 검증:"
  echo "     pnpm prisma validate"
  echo ""
  echo "  2. 개발 환경 마이그레이션:"
  echo "     pnpm prisma migrate dev --name <migration_name>"
  echo ""
  echo "  3. Prisma Client 재생성:"
  echo "     pnpm prisma generate"
  echo ""
  echo "  4. (선택) DB 시딩:"
  echo "     pnpm prisma db seed"
  echo ""
  echo "또는 /schema-design 명령어로 스키마 설계 검토를 받으세요."
  exit 0
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
