#!/bin/bash
# Server Action 파일 저장 시 인증 패턴 검사 스크립트
# Hook: PostToolUse (Write/Edit)

FILE="$1"

# _actions 폴더의 .ts 파일인지 확인
if [[ "$FILE" =~ _actions/.*\.ts$ ]]; then
  echo ""
  echo "Server Action 파일이 수정되었습니다: $FILE"
  echo ""

  # 파일 내용 검사
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
