---
name: error-handling
description: Error handling patterns — ALWAYS use when adding try-catch, returning errors from Server Actions or API Routes, handling DB errors, or creating error boundaries.
tested-with:
  enf: "1.1.0"
  next: "16.x"
  react: "19.x"
  drizzle-orm: "0.45.x"
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
  - error handling
---

# Error Handling Patterns

## Quick Reference

| Layer | Success | Expected Error | Unexpected Error |
|-------|---------|----------------|------------------|
| Server Action | `{ success: true }` | `{ error: "reason" }` | `{ error: "generic message" }` + console.error |
| API Route | `200/201` + JSON | `400/401/403/404` + JSON | `500` + JSON + console.error |
| Error Boundary | N/A | N/A | `error.tsx` / `global-error.tsx` |
| Client | toast.success | Inline / toast | Error Boundary catch |

---

## 1. Server Action Errors

### Response Type

```typescript
type ActionResult<T = void> =
  | { success: true; data?: T }
  | { error: string; fieldErrors?: Record<string, string[]> }
```

> **Why discriminated union?** `ActionResult`은 `success` 또는 `error` 필드 존재 여부로 타입이 좁혀지는 discriminated union. 서버/클라이언트 경계에서 직렬화 가능하면서도 타입 안전한 에러 전달을 보장하고, 클라이언트에서 `if (result.success)` 한 줄로 타입 가드가 완성됨.

### Base Pattern

```typescript
"use server"

import { auth } from "@/lib/auth"
import { db } from "@/db"
import { customers } from "@/db/schema"
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
    await db.insert(customers).values(parsed.data)
  } catch (error) {
    // → 섹션 3 "DB 에러" 패턴 참조
    return handleDbError(error)
  }

  // 4. 캐시 무효화
  revalidatePath("/admin/customers")
  return { success: true }
}
```

### fieldErrors Client Integration

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

## 2. API Route Errors

### Common Error Response (`apiError` Helper)

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

> For detailed API Route patterns (File Upload, External Webhook, External API Proxy, SSE), see [`references/api-route-patterns.md`](references/api-route-patterns.md).

---

## 3. Database Errors (PostgreSQL)

### handleDbError

```typescript
import { PostgresError } from 'postgres'

function handleDbError(error: unknown): { error: string } {
  if (error instanceof PostgresError) {
    switch (error.code) {
      case '23505': {
        // unique_violation
        if (error.detail?.includes('email')) {
          return { error: "이미 사용 중인 이메일입니다." }
        }
        return { error: "중복된 데이터가 존재합니다." }
      }
      case '23503':
        // foreign_key_violation
        return { error: "참조하는 데이터가 존재하지 않습니다." }
      case '23502':
        // not_null_violation
        return { error: "필수 항목이 누락되었습니다." }
      default:
        return { error: "데이터 처리 중 오류가 발생했습니다." }
    }
  }

  console.error("Unexpected error:", error)
  return { error: "알 수 없는 오류가 발생했습니다." }
}
```

> **Why PG error codes?** PostgreSQL은 에러 유형별로 표준화된 5자리 코드를 반환. 이 코드를 switch하면 `unique_violation(23505)` 같은 구조적 에러를 "이미 사용 중인 이메일입니다." 같은 사용자 친화적 메시지로 변환할 수 있어, 내부 구현을 노출하지 않으면서도 정확한 피드백 제공 가능.

### DB Errors in API Routes

```typescript
// API Route에서는 HTTP 상태 코드와 함께 반환
function handleDbApiError(error: unknown): NextResponse {
  if (error instanceof PostgresError) {
    switch (error.code) {
      case '23505':
        return NextResponse.json({ error: "중복된 데이터가 존재합니다." }, { status: 409 })
      case '23503':
        return NextResponse.json({ error: "참조 무결성 위반" }, { status: 400 })
      case '23502':
        return NextResponse.json({ error: "필수 항목 누락" }, { status: 400 })
      default:
        return NextResponse.json({ error: "데이터 처리 오류" }, { status: 500 })
    }
  }

  console.error("Unexpected error:", error)
  return NextResponse.json({ error: "서버 내부 오류" }, { status: 500 })
}
```

### Key PostgreSQL Error Codes

| Code | Description | HTTP | User Message |
|------|-------------|:----:|--------------|
| 23505 | unique_violation | 409 | "Duplicate data" |
| 23503 | foreign_key_violation | 400 | "Referenced data missing" |
| 23502 | not_null_violation | 400 | "Required field missing" |
| 08006 | connection_failure | 503 | "Temporarily unavailable" |

---

## 4. Transaction Errors

```typescript
try {
  const result = await db.transaction(async (tx) => {
    const [campaign] = await tx
      .update(campaigns)
      .set({ status: 'COMPLETED' })
      .where(eq(campaigns.id, campaignId))
      .returning()

    await tx
      .update(campaignInfluencers)
      .set({ status: 'COMPLETED' })
      .where(eq(campaignInfluencers.campaignId, campaignId))

    return campaign
  })

  revalidatePath("/admin/campaigns")
  return { success: true, data: result }
} catch (error) {
  // 트랜잭션은 자동 롤백됨
  return handleDbError(error)
}
```

---

## 5. Error Boundary (Next.js 16)

> **Why Error Boundaries?** React의 Error Boundary는 컴포넌트 트리의 일부에서 발생한 렌더링 에러를 격리하여, 단일 컴포넌트 실패가 전체 페이지를 크래시하지 않게 함. Next.js의 `error.tsx`는 라우트 세그먼트 단위로 자동 Error Boundary를 생성.

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

`notFound()`를 호출하면 가장 가까운 `not-found.tsx`가 렌더링됨:

```typescript
import { notFound } from "next/navigation"

const customer = await db.query.customers.findFirst({ where: eq(customers.id, id) })
if (!customer) notFound()
```

---

## 6. Client Errors

### useActionState + Error Display

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

### Optimistic Update Rollback

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

## 7. Important Notes

1. **Do not expose error details** -- never pass internal errors (stack traces, SQL, etc.) directly to the user
2. **console.error is mandatory** -- unexpected errors must always be logged on the server
3. **Use digest** -- track production errors using the `digest` that Next.js passes to Error Boundaries
4. **DB error import** -- import `PostgresError` from `postgres` package for error handling
5. **Follow HTTP status codes** -- API Routes must always return appropriate status codes (do not use only 200)
6. **Expected vs unexpected errors** -- use user-friendly messages for validation/auth failures; use generic messages for DB failures and similar issues
