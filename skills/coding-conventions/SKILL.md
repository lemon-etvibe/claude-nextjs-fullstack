---
name: coding-conventions
description: 코딩 컨벤션 가이드 - 컴포넌트, 함수, 변수 작성 시 참조. 코드 작성, 리팩토링, 코드 리뷰 작업에서 사용
tested-with:
  enf: "0.9.1"
  next: "16.x"
  typescript: "5.x"
triggers:
  - 컨벤션
  - 네이밍
  - 코드 스타일
  - import
  - 커밋
  - 주석
---

# 코딩 컨벤션

## 1. 네이밍 규칙

### 파일/폴더

| 대상          | 규칙       | 예시                |
| ------------- | ---------- | ------------------- |
| 컴포넌트      | PascalCase | `CustomerTable.tsx` |
| 유틸/훅       | camelCase  | `useCustomer.ts`    |
| 폴더          | kebab-case | `customer-form/`    |
| Server Action | camelCase  | `updateCustomer.ts` |

### 변수/함수

| 대상     | 규칙                | 예시             |
| -------- | ------------------- | ---------------- |
| 변수     | camelCase           | `customerList`   |
| 상수     | SCREAMING_SNAKE     | `API_BASE_URL`   |
| 함수     | camelCase + 동사    | `getCustomers()` |
| 컴포넌트 | PascalCase          | `CustomerCard`   |
| 훅       | use 접두사          | `useCustomers()` |
| 타입     | PascalCase (I 금지) | `Customer`       |
| Boolean  | is/has/should       | `isActive`       |

## 2. 주석 패턴

```typescript
// 단순 설명 (한글)
// 다음 페이지로 이동

/** JSDoc - 컴포넌트/함수 설명 */

{
  /* JSX 구조 주석 */
}

// TODO: 향후 작업
// FIXME: 버그 수정 필요
```

## 3. Import 순서

```typescript
// 1. React/Next.js
"use client"
import { useState } from "react"
import { headers } from "next/headers"

// 2. 외부 라이브러리
import { clsx } from "clsx"

// 3. 내부 모듈 (절대 경로)
import { Button } from "@/components/ui"
import { prisma } from "@/lib/prisma"
import { auth } from "@/lib/auth"

// 4. 내부 모듈 (상대 경로)
import { CustomerTable } from "./_components/CustomerTable"
import { updateCustomer } from "../../_actions/customer"

// 5. 타입 (type-only)
import type { Customer } from "@/generated/prisma"
```

## 4. TypeScript

- `any` 금지 → `unknown` 사용
- `as` 단언보다 타입 가드 선호
- 객체는 `interface`, 유니온은 `type`

## 5. Server Action 패턴

```typescript
// src/app/(admin)/_actions/customer.ts
"use server"

import { auth } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { revalidatePath } from "next/cache"
import { headers } from "next/headers"

export async function updateCustomer(id: string, prevState: unknown, formData: FormData) {
  // 1. 인증 체크
  const session = await auth.api.getSession({ headers: await headers() })
  if (!session) return { error: "권한이 없습니다." }

  // 2. Zod 검증
  // 3. DB 작업
  // 4. revalidatePath
  revalidatePath("/admin/customers")

  return { success: true }
}
```

## 6. Git 커밋

```
<type>: <한글 설명>

feat: 새 기능
fix: 버그 수정
refactor: 리팩토링
test: 테스트
docs: 문서
style: 포맷팅
chore: 빌드/설정
```

## 7. 에러 핸들링

> **상세 패턴**: `error-handling` 스킬 참조 — Server Action, API Route, Prisma, Error Boundary 에러 처리

```typescript
// 서버 - 유효성 검증
if (!valid) notFound();

// 클라이언트 - try-catch
try { ... } catch { return defaultValue; }

// 비동기 - finally 보장
try { await fetch(); } finally { cleanup(); }
```

## 8. ESLint/Prettier

- `no-explicit-any`: error
- `consistent-type-imports`: 강제
- `printWidth`: 100
- `singleQuote`: true
