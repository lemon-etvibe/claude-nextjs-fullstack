---
name: error-handling
description: 에러 핸들링 패턴 가이드 — Server Action, API Route, Prisma, Error Boundary 에러 처리
tested-with:
  enf: "0.9.1"
  next: "16.x"
  react: "19.x"
  prisma: "7.x"
  better-auth: "^1.4.0"
  typescript: "5.x"
triggers:
  - 에러
  - error
  - 에러 처리
  - 에러 핸들링
  - API Route
  - Error Boundary
  - 404
  - 500
---

# 에러 핸들링 패턴

## 1. Server Action 에러

### 응답 타입

```typescript
type ActionResult<T = void> =
  | { success: true; data?: T }
  | { error: string; fieldErrors?: Record<string, string[]> }
```

### 기본 패턴

```typescript
"use server"

import { auth } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { revalidatePath } from "next/cache"
import { headers } from "next/headers"

export async function createCustomer(
  prevState: unknown,
  formData: FormData
): Promise<ActionResult> {
  // 1. 인증
  const session = await auth.api.getSession({ headers: await headers() })
  if (!session || session.user.type !== "admin") {
    return { error: "권한이 없습니다." }
  }

  // 2. Zod 검증
  const parsed = customerSchema.safeParse(Object.fromEntries(formData))
  if (!parsed.success) {
    return {
      error: "입력값을 확인해주세요.",
      fieldErrors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
    }
  }

  // 3. DB 작업 (try-catch)
  try {
    await prisma.customer.create({ data: parsed.data })
  } catch (error) {
    // → 섹션 3 "Prisma 에러" 패턴 참조
    return handlePrismaError(error)
  }

  // 4. 캐시 무효화
  revalidatePath("/admin/customers")
  return { success: true }
}
```

### fieldErrors 클라이언트 연동

```tsx
"use client"

import { useActionState } from "react"

function CustomerForm() {
  const [state, action, isPending] = useActionState(createCustomer, null)

  return (
    <form action={action}>
      <input name="email" />
      {state?.fieldErrors?.email && (
        <p className="text-sm text-destructive">{state.fieldErrors.email[0]}</p>
      )}

      {state?.error && !state.fieldErrors && (
        <p className="text-sm text-destructive">{state.error}</p>
      )}

      <button type="submit" disabled={isPending}>
        {isPending ? "저장 중..." : "저장"}
      </button>
    </form>
  )
}
```

---

## 2. API Route 에러 (Next.js 16 Route Handlers)

### 공통 에러 응답

```typescript
// src/lib/api-error.ts
import { NextResponse } from "next/server"

type ApiErrorResponse = {
  error: string
  code?: string
}

export function apiError(
  message: string,
  status: number,
  code?: string
): NextResponse<ApiErrorResponse> {
  return NextResponse.json({ error: message, code }, { status })
}
```

### 2-1. 파일 업로드

```typescript
// src/app/api/files/route.ts
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { NextRequest, NextResponse } from "next/server"

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp", "application/pdf"]

export async function POST(request: NextRequest) {
  // 1. 인증
  const session = await auth.api.getSession({ headers: await headers() })
  if (!session) {
    return NextResponse.json({ error: "인증이 필요합니다." }, { status: 401 })
  }

  // 2. 파싱 + 검증
  try {
    const formData = await request.formData()
    const file = formData.get("file") as File | null

    if (!file) {
      return NextResponse.json({ error: "파일이 필요합니다." }, { status: 400 })
    }
    if (file.size > MAX_FILE_SIZE) {
      return NextResponse.json({ error: "파일 크기는 10MB 이하여야 합니다." }, { status: 400 })
    }
    if (!ALLOWED_TYPES.includes(file.type)) {
      return NextResponse.json({ error: "허용되지 않는 파일 형식입니다." }, { status: 400 })
    }

    // 3. 처리
    const bytes = await file.arrayBuffer()
    // ... storage logic

    return NextResponse.json({ success: true, url: "..." }, { status: 201 })
  } catch {
    return NextResponse.json({ error: "파일 업로드 중 오류가 발생했습니다." }, { status: 500 })
  }
}
```

### 2-2. 외부 웹훅

```typescript
// src/app/api/webhooks/[provider]/route.ts
import { NextRequest, NextResponse } from "next/server"

export async function POST(request: NextRequest) {
  // 1. 서명 검증 (세션 인증 아님 — 외부 호출자)
  const signature = request.headers.get("x-webhook-signature")
  if (!signature) {
    return NextResponse.json({ error: "서명이 필요합니다." }, { status: 401 })
  }

  const body = await request.text()
  const isValid = verifySignature(body, signature, process.env.WEBHOOK_SECRET!)
  if (!isValid) {
    return NextResponse.json({ error: "유효하지 않은 서명입니다." }, { status: 403 })
  }

  // 2. 처리
  try {
    const payload = JSON.parse(body) as unknown
    // ... business logic
    return NextResponse.json({ received: true })
  } catch {
    return NextResponse.json({ error: "처리 중 오류가 발생했습니다." }, { status: 500 })
  }
}
```

### 2-3. 외부 API 프록시

```typescript
// src/app/api/external/[service]/route.ts
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  const session = await auth.api.getSession({ headers: await headers() })
  if (!session) {
    return NextResponse.json({ error: "인증이 필요합니다." }, { status: 401 })
  }

  try {
    const response = await fetch(EXTERNAL_API_URL, {
      headers: { Authorization: `Bearer ${process.env.EXTERNAL_API_KEY}` },
      signal: AbortSignal.timeout(5000), // 5초 타임아웃
    })

    if (!response.ok) {
      return NextResponse.json(
        { error: "외부 서비스 응답 오류", code: `EXTERNAL_${response.status}` },
        { status: 502 }
      )
    }

    const data: unknown = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof DOMException && error.name === "AbortError") {
      return NextResponse.json({ error: "외부 서비스 응답 시간 초과" }, { status: 504 })
    }
    return NextResponse.json({ error: "외부 서비스 연결 실패" }, { status: 502 })
  }
}
```

### 2-4. SSE (Server-Sent Events)

```typescript
// src/app/api/events/route.ts
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  const session = await auth.api.getSession({ headers: await headers() })
  if (!session) {
    return NextResponse.json({ error: "인증이 필요합니다." }, { status: 401 })
  }

  const encoder = new TextEncoder()
  const stream = new ReadableStream({
    async start(controller) {
      try {
        // ... 이벤트 푸시
        controller.enqueue(encoder.encode(`data: ${JSON.stringify({ type: "update" })}\n\n`))
      } catch {
        controller.enqueue(encoder.encode(`data: ${JSON.stringify({ type: "error" })}\n\n`))
        controller.close()
      }
    },
  })

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  })
}
```

---

## 3. Prisma 에러

### 에러 코드별 처리

```typescript
import { Prisma } from "@/generated/prisma"

function handlePrismaError(error: unknown): { error: string } {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    switch (error.code) {
      case "P2002": {
        // Unique constraint violation
        const target = (error.meta?.target as string[]) ?? []
        if (target.includes("email")) {
          return { error: "이미 사용 중인 이메일입니다." }
        }
        return { error: "중복된 데이터가 존재합니다." }
      }
      case "P2025":
        // Record not found
        return { error: "데이터를 찾을 수 없습니다." }
      case "P2003":
        // Foreign key constraint failure
        return { error: "참조하는 데이터가 존재하지 않습니다." }
      default:
        return { error: "데이터 처리 중 오류가 발생했습니다." }
    }
  }

  if (error instanceof Prisma.PrismaClientInitializationError) {
    // P2024: Connection pool timeout 등
    console.error("Prisma connection error:", error.message)
    return { error: "서비스가 일시적으로 불안정합니다. 잠시 후 다시 시도해주세요." }
  }

  console.error("Unexpected error:", error)
  return { error: "알 수 없는 오류가 발생했습니다." }
}
```

### API Route에서 Prisma 에러

```typescript
// API Route에서는 HTTP 상태 코드와 함께 반환
function handlePrismaApiError(error: unknown): NextResponse {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    switch (error.code) {
      case "P2002":
        return NextResponse.json({ error: "중복된 데이터가 존재합니다." }, { status: 409 })
      case "P2025":
        return NextResponse.json({ error: "데이터를 찾을 수 없습니다." }, { status: 404 })
      case "P2003":
        return NextResponse.json({ error: "참조 무결성 위반" }, { status: 400 })
      default:
        return NextResponse.json({ error: "데이터 처리 오류" }, { status: 500 })
    }
  }

  console.error("Unexpected error:", error)
  return NextResponse.json({ error: "서버 내부 오류" }, { status: 500 })
}
```

### 주요 Prisma 에러 코드

| 코드 | 설명 | HTTP | 사용자 메시지 |
|------|------|:----:|--------------|
| P2002 | Unique constraint | 409 | "중복된 데이터" |
| P2025 | Record not found | 404 | "찾을 수 없음" |
| P2003 | Foreign key 위반 | 400 | "참조 데이터 없음" |
| P2024 | Connection timeout | 503 | "일시적 불안정" |

---

## 4. 트랜잭션 에러

```typescript
try {
  const result = await prisma.$transaction(async (tx) => {
    const campaign = await tx.campaign.update({
      where: { id: campaignId },
      data: { status: "COMPLETED" },
    })

    await tx.campaignInfluencer.updateMany({
      where: { campaignId },
      data: { status: "COMPLETED" },
    })

    return campaign
  })

  revalidatePath("/admin/campaigns")
  return { success: true, data: result }
} catch (error) {
  // 트랜잭션은 자동 롤백됨
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    return handlePrismaError(error)
  }
  console.error("Transaction failed:", error)
  return { error: "작업 처리 중 오류가 발생했습니다. 변경사항이 취소되었습니다." }
}
```

---

## 5. Error Boundary (Next.js 16)

### error.tsx (Route Segment)

```tsx
// src/app/(admin)/admin/(protected)/error.tsx
"use client"

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="flex flex-col items-center justify-center gap-4 p-8">
      <h2 className="text-xl font-semibold">문제가 발생했습니다</h2>
      <p className="text-muted-foreground">
        잠시 후 다시 시도해주세요.
      </p>
      <button
        onClick={reset}
        className="rounded-md bg-primary px-4 py-2 text-primary-foreground"
      >
        다시 시도
      </button>
    </div>
  )
}
```

### global-error.tsx (Root Layout)

```tsx
// src/app/global-error.tsx
"use client"

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <div className="flex min-h-screen flex-col items-center justify-center gap-4">
          <h2 className="text-xl font-semibold">심각한 오류가 발생했습니다</h2>
          <button onClick={reset}>다시 시도</button>
        </div>
      </body>
    </html>
  )
}
```

### not-found.tsx

```tsx
// src/app/(admin)/admin/(protected)/customers/[id]/not-found.tsx
import Link from "next/link"

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center gap-4 p-8">
      <h2 className="text-xl font-semibold">고객을 찾을 수 없습니다</h2>
      <Link
        href="/admin/customers"
        className="text-primary underline"
      >
        목록으로 돌아가기
      </Link>
    </div>
  )
}
```

### Server Component에서 notFound() 호출

```typescript
import { notFound } from "next/navigation"

export default async function CustomerPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const customer = await prisma.customer.findUnique({
    where: { id },
    select: { id: true, name: true, email: true },
  })

  if (!customer) notFound()

  return <CustomerDetail customer={customer} />
}
```

---

## 6. 클라이언트 에러

### useActionState + 에러 표시

```tsx
"use client"

import { useActionState } from "react"
import { toast } from "sonner"
import { useEffect } from "react"

function CustomerForm() {
  const [state, action, isPending] = useActionState(updateCustomer, null)

  useEffect(() => {
    if (state?.error && !state.fieldErrors) {
      toast.error(state.error)
    }
    if (state?.success) {
      toast.success("저장되었습니다.")
    }
  }, [state])

  return (
    <form action={action}>
      {/* 필드별 에러: 인라인 표시 */}
      {/* 일반 에러: toast 표시 */}
    </form>
  )
}
```

### 낙관적 업데이트 롤백

```tsx
"use client"

import { useOptimistic } from "react"

function ToggleStatus({ item }: { item: Item }) {
  const [optimisticStatus, setOptimisticStatus] = useOptimistic(item.status)

  async function handleToggle() {
    const newStatus = optimisticStatus === "ACTIVE" ? "INACTIVE" : "ACTIVE"
    setOptimisticStatus(newStatus)

    const result = await toggleItemStatus(item.id)
    if (result?.error) {
      // 실패 시 서버 상태가 자동 반영됨 (revalidate)
      toast.error(result.error)
    }
  }

  return <button onClick={handleToggle}>{optimisticStatus}</button>
}
```

---

## 7. Quick Reference

| 레이어 | 성공 | 예상된 에러 | 예상치 못한 에러 |
|--------|------|------------|-----------------|
| Server Action | `{ success: true }` | `{ error: "사유" }` | `{ error: "일반 메시지" }` + console.error |
| API Route | `200/201` + JSON | `400/401/403/404` + JSON | `500` + JSON + console.error |
| Error Boundary | N/A | N/A | `error.tsx` / `global-error.tsx` |
| 클라이언트 | toast.success | 인라인/toast | Error Boundary catch |

---

## 8. 주의사항

1. **에러 메시지 노출 금지** — 내부 에러(스택 트레이스, SQL 등)를 사용자에게 직접 전달하지 않는다
2. **console.error 필수** — 예상치 못한 에러는 반드시 서버 로그에 기록한다
3. **digest 활용** — Next.js가 Error Boundary에 전달하는 `digest`로 프로덕션 에러를 추적한다
4. **Prisma import 경로** — Prisma 7에서는 `@/generated/prisma`에서 import한다 (`@prisma/client` 아님)
5. **HTTP 상태 코드 준수** — API Route는 항상 적절한 상태 코드를 반환한다 (200만 사용하지 않는다)
6. **예상된 에러 vs 예상치 못한 에러** — 검증/인증 실패는 사용자 친화적 메시지, DB 장애 등은 일반 메시지로 구분한다
