#!/bin/bash
# Prisma 스키마 수정 시 마이그레이션 안내 스크립트
# Hook: PostToolUse (Write/Edit)

FILE="$1"

# schema.prisma 파일인지 확인
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
fi
