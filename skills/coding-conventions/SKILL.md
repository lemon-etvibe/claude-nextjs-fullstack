---
name: coding-conventions
description: Coding conventions guide - reference for components, functions, and variables. Used for code writing, refactoring, and code review.
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
  - convention
  - naming
  - code style
  - commit
  - comment
---

# Coding Conventions

## 1. Naming Rules

### Files/Folders

| Target         | Rule       | Example             |
| -------------- | ---------- | ------------------- |
| Component      | PascalCase | `CustomerTable.tsx` |
| Utility/Hook   | camelCase  | `useCustomer.ts`    |
| Folder         | kebab-case | `customer-form/`    |
| Server Action  | camelCase  | `updateCustomer.ts` |

### Variables/Functions

| Target    | Rule                | Example          |
| --------- | ------------------- | ---------------- |
| Variable  | camelCase           | `customerList`   |
| Constant  | SCREAMING_SNAKE     | `API_BASE_URL`   |
| Function  | camelCase + verb    | `getCustomers()` |
| Component | PascalCase          | `CustomerCard`   |
| Hook      | use prefix          | `useCustomers()` |
| Type      | PascalCase (no I)   | `Customer`       |
| Boolean   | is/has/should       | `isActive`       |

## 2. Comment Patterns

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

## 3. Import Order

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

- No `any` — use `unknown` instead
- Prefer type guards over `as` assertions
- Use `interface` for objects, `type` for unions

## 5. Server Action Pattern

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

## 6. Git Commits

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

## 7. Error Handling

> **Detailed patterns**: See `error-handling` skill — covers Server Action, API Route, Prisma, and Error Boundary error handling

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
- `consistent-type-imports`: enforced
- `printWidth`: 100
- `singleQuote`: true
