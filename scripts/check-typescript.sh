#!/bin/bash
# TypeScript/TSX 파일 저장 시 안내 스크립트
# Hook: PostToolUse (Write/Edit)

FILE="$1"

# .ts 또는 .tsx 파일인지 확인
if [[ "$FILE" =~ \.(ts|tsx)$ ]]; then
  echo ""
  echo "TypeScript 파일이 수정되었습니다: $FILE"
  echo ""
  echo "권장 검사:"
  echo "  1. pnpm tsc --noEmit     # 타입 검사"
  echo "  2. pnpm lint             # ESLint 검사"
  echo ""
  echo "또는 /type-check 명령어를 사용하세요."
fi
