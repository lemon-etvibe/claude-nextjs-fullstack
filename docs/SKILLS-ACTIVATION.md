# 스킬 활성화 가이드

etvibe-nextjs-fullstack (enf) 플러그인의 4개 스킬 상세 가이드입니다.

---

## 목차

- [개요](#개요)
- [coding-conventions](#coding-conventions)
- [better-auth](#better-auth)
- [prisma-7](#prisma-7)
- [tailwind-v4-shadcn](#tailwind-v4-shadcn)
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
| `prisma-7` | Prisma, 스키마, 마이그레이션 | DB 작업 |
| `tailwind-v4-shadcn` | Tailwind, shadcn, 폼, 스타일 | UI 스타일링 |

### 활성화 방식

```bash
# 자동 활성화 (키워드 감지)
> 로그인 기능을 구현해줘
# → better-auth 스킬 자동 활성화

# 명시적 활성화
> better-auth 패턴으로 세션 관리를 구현해줘
```

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
import { prisma } from "@/lib/prisma"

// 4. 내부 모듈 (상대 경로)
import { CustomerTable } from "./_components/CustomerTable"

// 5. 타입 (type-only)
import type { Customer } from "@/generated/prisma"
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

## prisma-7

### 활성화 조건

- 키워드: `Prisma`, `스키마`, `마이그레이션`, `데이터베이스`, `DB`
- 데이터 모델링, 쿼리 작성 시

### 핵심 내용

#### 1. Prisma 7 필수 설정

```
프로젝트 루트/
├── prisma.config.ts    # 필수! CLI 설정
├── prisma/
│   └── schema.prisma
└── .env
```

```typescript
// prisma.config.ts
import "dotenv/config"
import { defineConfig } from "prisma/config"

export default defineConfig({
  earlyAccess: true,
  schema: "prisma/schema.prisma",
})
```

#### 2. pg Adapter 설정

```typescript
// src/lib/prisma.ts
import { Pool } from "pg"
import { PrismaPg } from "@prisma/adapter-pg"
import { PrismaClient } from "@/generated/prisma"

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

const adapter = new PrismaPg(pool)

export const prisma = new PrismaClient({ adapter })
```

#### 3. 스키마 패턴

```prisma
// 1:N 관계
model Customer {
  id        String     @id @default(cuid())
  campaigns Campaign[]
  @@map("customers")
}

model Campaign {
  id         String   @id @default(cuid())
  customerId String
  customer   Customer @relation(fields: [customerId], references: [id])
  @@index([customerId])
  @@map("campaigns")
}

// N:M 관계 (중간 테이블)
model CampaignInfluencer {
  campaignId   String
  influencerId String
  campaign     Campaign   @relation(...)
  influencer   Influencer @relation(...)
  @@id([campaignId, influencerId])
}
```

#### 4. 쿼리 패턴

```typescript
// ✅ 필요한 필드만 선택
const customers = await prisma.customer.findMany({
  select: {
    id: true,
    name: true,
    _count: { select: { campaigns: true } },
  },
})

// ✅ 관계 로드
const customer = await prisma.customer.findUnique({
  where: { id },
  include: {
    campaigns: {
      select: { id: true, name: true },
      orderBy: { createdAt: "desc" },
      take: 5,
    },
  },
})
```

#### 5. 마이그레이션 명령어

```bash
# 개발용 (스키마 동기화)
pnpm prisma db push

# 프로덕션용 (마이그레이션 생성)
pnpm prisma migrate dev --name add_feature

# Client 재생성
pnpm prisma generate

# DB 브라우저
pnpm prisma studio
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

## 스킬 활용 팁

### 1. 복합 스킬 활용

여러 스킬이 동시에 필요한 경우:

```bash
> Better Auth 로그인 폼을 shadcn 컴포넌트로 만들어줘
# → better-auth + tailwind-v4-shadcn 동시 활성화
```

### 2. 스킬 내용 직접 참조

```bash
> skills/prisma-7/SKILL.md 내용을 보여줘
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
| prisma-7 | pg adapter, select/include, 마이그레이션 |
| tailwind-v4-shadcn | @theme 디렉티브, Form 패턴, useActionState |

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [GUIDELINES](./GUIDELINES.md) | 플러그인 철학 |
| [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 매뉴얼 |
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 시나리오별 가이드 |
| [TEAM-ONBOARDING](./TEAM-ONBOARDING.md) | 팀 온보딩 |
