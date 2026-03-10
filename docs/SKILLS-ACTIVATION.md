# 스킬 활성화 가이드

etvibe-nextjs-fullstack (enf) 플러그인의 6개 스킬 상세 가이드입니다.

---

## 목차

- [개요](#개요)
- [coding-conventions](#coding-conventions)
- [better-auth](#better-auth)
- [drizzle](#drizzle)
- [tailwind-v4-shadcn](#tailwind-v4-shadcn)
- [testing](#testing)
- [error-handling](#error-handling)
- [스킬 활용 팁](#스킬-활용-팁)

---

## 개요

### 스킬이란?

스킬은 특정 기술 영역의 지식 베이스입니다. 관련 키워드를 언급하면 자동으로 활성화되어 해당 분야의 베스트 프랙티스를 적용합니다.

### 스킬 목록

| Skill | 활성화 키워드 | 용도 |
|-------|--------------|------|
| `coding-conventions` | 컨벤션, 네이밍, 코드 스타일 | 코드 작성 규칙 |
| `better-auth` | 인증, 세션, 로그인, Better Auth | 인증 구현 |
| `drizzle` | Drizzle, 스키마, 마이그레이션, pgTable | DB 작업 |
| `tailwind-v4-shadcn` | Tailwind, shadcn, 폼, 스타일 | UI 스타일링 |
| `testing` | 테스트, vitest, playwright, E2E | 테스트 작성 |
| `error-handling` | 에러, API Route, Error Boundary | 에러 처리 패턴 |

### 활성화 방식

```bash
# 자동 활성화 (키워드 감지)
> 로그인 기능을 구현해줘
# → better-auth 스킬 자동 활성화

# 명시적 활성화
> better-auth 패턴으로 세션 관리를 구현해줘
```

### 검증 버전 (tested-with)

각 스킬의 frontmatter에는 `tested-with` 메타데이터가 포함되어 있어, 해당 스킬 내용이 검증된 기술 스택 버전을 명시합니다. `/enf:health` 커맨드로 프로젝트와의 호환성을 자동 확인할 수 있습니다.

> **상세 정보**: [COMPATIBILITY.md](./COMPATIBILITY.md) — 지원 버전 매트릭스

---

## coding-conventions

### 활성화 조건

- 키워드: `컨벤션`, `네이밍`, `코드 스타일`, `import 순서`
- 코드 작성, 리팩토링, 코드 리뷰 작업 시

### 핵심 내용

#### 1. 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 컴포넌트 파일 | PascalCase | `CustomerTable.tsx` |
| 유틸/훅 파일 | camelCase | `useCustomer.ts` |
| 폴더 | kebab-case | `customer-form/` |
| 변수 | camelCase | `customerList` |
| 상수 | SCREAMING_SNAKE | `API_BASE_URL` |
| 함수 | camelCase + 동사 | `getCustomers()` |
| 타입 | PascalCase (I 금지) | `Customer` |
| Boolean | is/has/should | `isActive` |

#### 2. Import 순서

```typescript
// 1. React/Next.js
"use client"
import { useState } from "react"
import { headers } from "next/headers"

// 2. 외부 라이브러리
import { clsx } from "clsx"

// 3. 내부 모듈 (절대 경로)
import { Button } from "@/components/ui"
import { db } from "@/db"

// 4. 내부 모듈 (상대 경로)
import { CustomerTable } from "./_components/CustomerTable"

// 5. 타입 (type-only)
import type { Customer } from "@/db/schema"
```

#### 3. TypeScript 규칙

- `any` 금지 → `unknown` 사용
- `as` 단언보다 타입 가드 선호
- 객체는 `interface`, 유니온은 `type`

#### 4. Git 커밋 메시지

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

---

## better-auth

### 활성화 조건

- 키워드: `인증`, `세션`, `로그인`, `로그아웃`, `Better Auth`, `권한`
- 인증/인가 관련 코드 작성 시

### 핵심 내용

#### 1. 서버 컴포넌트에서 세션 확인

```typescript
// layout.tsx
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export default async function ProtectedLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    redirect("/admin/login")
  }

  if (session.user.type !== "admin") {
    redirect("/admin/login?error=unauthorized")
  }

  return <>{children}</>
}
```

#### 2. Server Action에서 인증

```typescript
"use server"

import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export async function updateCustomer(
  id: string,
  prevState: unknown,
  formData: FormData
) {
  // 1. 인증 체크
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: "로그인이 필요합니다." }
  }

  // 2. 권한 체크
  if (session.user.type !== "admin") {
    return { error: "권한이 없습니다." }
  }

  // 3. 비즈니스 로직
  // ...
}
```

#### 3. 클라이언트에서 세션 사용

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
})

export const { useSession, signIn, signOut } = authClient
```

```tsx
"use client"

import { useSession, signOut } from "@/lib/auth-client"

export function UserMenu() {
  const { data: session, isPending } = useSession()

  if (isPending) return <Skeleton />
  if (!session) return <LoginButton />

  return (
    <div>
      <span>{session.user.name}</span>
      <button onClick={() => signOut()}>로그아웃</button>
    </div>
  )
}
```

#### 4. 로그인 폼

```tsx
"use client"

import { signIn } from "@/lib/auth-client"

const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault()
  const formData = new FormData(e.currentTarget)

  const { error } = await signIn.email({
    email: formData.get("email") as string,
    password: formData.get("password") as string,
  })

  if (error) {
    setError(error.message)
    return
  }

  router.push("/admin")
  router.refresh()
}
```

---

## drizzle

### 활성화 조건

- 키워드: `Drizzle`, `스키마`, `마이그레이션`, `데이터베이스`, `DB`, `pgTable`
- 데이터 모델링, 쿼리 작성 시

### 핵심 내용

#### 1. 프로젝트 구조

```
프로젝트 루트/
├── drizzle.config.ts    # drizzle-kit 설정
├── src/db/
│   ├── index.ts         # DB 연결 (싱글톤)
│   ├── schema.ts        # 스키마 정의
│   └── migrations/      # 마이그레이션 파일
└── .env
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const globalForDb = globalThis as unknown as { db: ReturnType<typeof drizzle> }

export const db =
  globalForDb.db ||
  drizzle(postgres(process.env.DATABASE_URL!), { schema })

if (process.env.NODE_ENV !== 'production') globalForDb.db = db
```

#### 2. 스키마 패턴

```typescript
// src/db/schema.ts
import { pgTable, text, timestamp, index } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { createId } from '@paralleldrive/cuid2'

// 1:N 관계
export const customers = pgTable('customers', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  name: text('name').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
})

export const campaigns = pgTable('campaigns', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  customerId: text('customer_id').notNull().references(() => customers.id),
}, (table) => [
  index('campaigns_customer_id_idx').on(table.customerId),
])

// relations 정의 (query API용)
export const customersRelations = relations(customers, ({ many }) => ({
  campaigns: many(campaigns),
}))

export const campaignsRelations = relations(campaigns, ({ one }) => ({
  customer: one(customers, {
    fields: [campaigns.customerId],
    references: [customers.id],
  }),
}))
```

#### 3. 쿼리 패턴

```typescript
// ✅ 필요한 필드만 선택
const customerList = await db.query.customers.findMany({
  columns: { id: true, name: true },
  with: { campaigns: { columns: { id: true, name: true } } },
})

// ✅ 조건 검색
import { eq } from 'drizzle-orm'
const customer = await db.query.customers.findFirst({
  where: eq(customers.id, id),
  with: { campaigns: { limit: 5, orderBy: (c, { desc }) => [desc(c.createdAt)] } },
})
```

#### 4. 마이그레이션 명령어

```bash
# 마이그레이션 파일 생성
npx drizzle-kit generate

# 마이그레이션 적용
npx drizzle-kit migrate

# 빠른 프로토타이핑 (마이그레이션 없이)
npx drizzle-kit push

# DB 브라우저
npx drizzle-kit studio
```

---

## tailwind-v4-shadcn

### 활성화 조건

- 키워드: `Tailwind`, `shadcn`, `폼`, `스타일`, `UI 컴포넌트`
- UI 스타일링, 폼 구현 시

### 핵심 내용

#### 1. Tailwind v4 CSS-first 설정

```css
/* globals.css */
@import "tailwindcss";

@theme {
  --color-primary: #0059ff;
  --color-secondary: #111111;
  --font-sans: "Pretendard Variable", sans-serif;
}
```

> `tailwind.config.js` 대신 CSS `@theme` 디렉티브 사용

#### 2. shadcn/ui 폼 패턴

```tsx
"use client"

import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

const formSchema = z.object({
  name: z.string().min(2, "이름은 2자 이상"),
  email: z.string().email("유효한 이메일 입력"),
})

export function CustomerForm() {
  const form = useForm({
    resolver: zodResolver(formSchema),
    defaultValues: { name: "", email: "" },
  })

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>이름</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">저장</Button>
      </form>
    </Form>
  )
}
```

#### 3. Server Action과 함께 사용

```tsx
"use client"

import { useActionState } from "react"
import { updateCustomer } from "../_actions/customer"

export function CustomerEditForm({ customer }) {
  const [state, formAction, pending] = useActionState(
    updateCustomer.bind(null, customer.id),
    null
  )

  return (
    <form action={formAction}>
      {/* 폼 필드 */}
      {state?.error && <p className="text-destructive">{state.error}</p>}
      <Button disabled={pending}>
        {pending ? "저장 중..." : "저장"}
      </Button>
    </form>
  )
}
```

#### 4. 다이얼로그/모달

```tsx
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"

export function CustomerDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>고객 추가</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>새 고객 등록</DialogTitle>
        </DialogHeader>
        <CustomerForm />
      </DialogContent>
    </Dialog>
  )
}
```

#### 5. 테마 커스터마이징

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 0 0% 6.7%;
    --primary: 220 100% 50%;
    --primary-foreground: 0 0% 100%;
  }
}
```

---

## testing

### 활성화 조건

- 키워드: `테스트`, `test`, `vitest`, `playwright`, `testing library`, `E2E`
- 테스트 작성, 테스트 실행, 커버리지 분석 시

### 핵심 내용

#### 1. Server Action 테스트 패턴

```typescript
// 중앙 mock (src/test/mocks.ts) import 후 사용
import { mockGetSession, mockDb } from "@/test/mocks"
import { createFormData, mockSession } from "@/test/helpers"

it("인증 실패 → 에러 반환", async () => {
  mockGetSession.mockResolvedValue(null)
  const result = await updateCustomer("id-1", undefined, createFormData({ name: "홍길동" }))
  expect(result).toEqual({ error: "인증이 필요합니다." })
})
```

#### 2. 컴포넌트 테스트 패턴

```tsx
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"

it("폼 제출", async () => {
  const user = userEvent.setup()
  render(<CustomerForm action={vi.fn()} />)
  await user.type(screen.getByLabelText("이름"), "홍길동")
  await user.click(screen.getByRole("button", { name: "저장" }))
})
```

#### 3. E2E 테스트 패턴

```typescript
// Page Object + Playwright
const loginPage = new LoginPage(page)
await loginPage.goto()
await loginPage.login("admin@test.com", "password123")
await expect(page).toHaveURL("/admin/dashboard")
```

#### 4. 테스트 파일 규칙

| 파일 유형 | 패턴 | 위치 |
|-----------|------|------|
| 단위 테스트 | `*.test.ts` | 소스 옆 `__tests__/` |
| 컴포넌트 테스트 | `*.test.tsx` | 소스 옆 `__tests__/` |
| E2E 테스트 | `*.spec.ts` | `e2e/` 최상위 |

---

## error-handling

### 활성화 조건

- 키워드: `에러`, `error`, `에러 처리`, `API Route`, `Error Boundary`, `404`, `500`
- 에러 처리 구현, API Route 작성, Error Boundary 설정 시

### 핵심 내용

#### 1. Server Action 에러 응답

```typescript
type ActionResult<T = void> =
  | { success: true; data?: T }
  | { error: string; fieldErrors?: Record<string, string[]> }
```

#### 2. API Route 에러 패턴 (4가지)

| 패턴 | HTTP 상태 코드 | 사용처 |
|------|:-------------:|--------|
| 파일 업로드 | 400, 401, 500 | multipart/form-data |
| 외부 웹훅 | 401, 403, 500 | 서명 검증 |
| 외부 API 프록시 | 401, 502, 504 | 타임아웃, 프록시 에러 |
| SSE | 401 | 스트리밍 이벤트 |

#### 3. Database 에러 코드 (PostgreSQL)

| 코드 | 설명 | Server Action | API Route |
|------|------|:------------:|:---------:|
| 23505 | Unique 위반 | `{ error: "중복" }` | 409 |
| 23503 | FK 위반 | `{ error: "참조 없음" }` | 400 |
| 23502 | NOT NULL 위반 | `{ error: "필수 값 누락" }` | 400 |

#### 4. Error Boundary

- `error.tsx` — Route segment 에러 (가장 많이 사용)
- `global-error.tsx` — Root layout 에러
- `not-found.tsx` — 404 페이지

### 사용 예시

```bash
# API Route 에러 처리
> 파일 업로드 API Route를 만들어줘

# DB 에러 처리
> Server Action에 DB 에러 처리를 추가해줘

# Error Boundary
> 고객 상세 페이지에 error.tsx와 not-found.tsx를 추가해줘
```

---

## 스킬 활용 팁

### 1. 복합 스킬 활용

여러 스킬이 동시에 필요한 경우:

```bash
> Better Auth 로그인 폼을 shadcn 컴포넌트로 만들어줘
# → better-auth + tailwind-v4-shadcn 동시 활성화
```

### 2. 스킬 내용 직접 참조

```bash
> skills/drizzle/SKILL.md 내용을 보여줘
```

### 3. 특정 스킬 강조

```bash
> coding-conventions 규칙을 엄격하게 적용해서 이 코드를 리팩토링해줘
```

### 4. 스킬별 주요 패턴 요약

| Skill | 핵심 패턴 |
|-------|----------|
| coding-conventions | Import 순서, 네이밍 규칙, 커밋 메시지 |
| better-auth | `await headers()` 필수, 권한 체크 패턴 |
| drizzle | pgTable 스키마, columns/with 쿼리, drizzle-kit CLI |
| tailwind-v4-shadcn | @theme 디렉티브, Form 패턴, useActionState |
| testing | Server Action mock, 컴포넌트 render, Playwright Page Object |
| error-handling | ActionResult 타입, DB 에러 코드, Error Boundary |

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [GUIDELINES](./GUIDELINES.md) | 플러그인 철학 |
| [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 매뉴얼 |
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 시나리오별 가이드 |
| [TEAM-ONBOARDING](./TEAM-ONBOARDING.md) | 팀 온보딩 |
