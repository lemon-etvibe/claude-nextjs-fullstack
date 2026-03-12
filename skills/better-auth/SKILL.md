---
name: better-auth
description: Better Auth authentication patterns — ALWAYS use when implementing login, signup, session checks, role-based access, or any auth-related code.
tested-with:
  enf: "1.0.0"
  next: "16.x"
  better-auth: "^1.4.0"
  typescript: "5.x"
triggers:
  - 인증
  - 로그인
  - 세션
  - 권한
  - auth
  - 로그아웃
  - 회원가입
  - authentication
  - login
  - session
  - authorization
  - logout
  - signup
---

# Better Auth Authentication Guide

## Installation & Setup

### 1. Installation

```bash
pnpm add better-auth
```

### 2. Environment Variables

```env
# .env.local
BETTER_AUTH_SECRET="min-32-chars-random-string-here"
BETTER_AUTH_URL="http://localhost:3000"
DATABASE_URL="postgresql://..."
```

### 3. Auth Configuration

```typescript
// src/lib/auth.ts
import { betterAuth } from "better-auth"
import { drizzleAdapter } from "better-auth/adapters/drizzle"
import { db } from "@/db"

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
  }),

  // 세션 설정
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7일
    updateAge: 60 * 60 * 24, // 1일마다 갱신
  },

  // 이메일/비밀번호 인증
  emailAndPassword: {
    enabled: true,
    minPasswordLength: 8,
  },

  // 사용자 필드 확장
  user: {
    additionalFields: {
      type: {
        type: "string",
        defaultValue: "customer",
      },
    },
  },
})

export type Session = typeof auth.$Infer.Session
```

### 4. API Route

```typescript
// src/app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth"
import { toNextJsHandler } from "better-auth/next-js"

export const { GET, POST } = toNextJsHandler(auth)
```

---

## Session Management Patterns

### Checking Session in Server Component

```typescript
// src/app/(admin)/admin/(protected)/layout.tsx
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

  // 역할 체크
  if (session.user.type !== "admin") {
    redirect("/admin/login?error=unauthorized")
  }

  return <>{children}</>
}
```

> **Why 2-layer session checks (Proxy + Server Component)?** Proxy(`proxy.ts`)는 쿠키 존재 여부만 확인하는 빠른 리다이렉트 레이어이고, Server Component는 실제 DB에서 세션 유효성을 검증하는 레이어. Proxy만으로는 만료된 세션이나 탈취된 토큰을 걸러낼 수 없고, Server Component만으로는 불필요한 렌더링 비용이 발생. 2계층으로 빠른 차단 + 정확한 검증을 분리.

### Authentication in Server Action

```typescript
// src/app/(admin)/_actions/customer.ts
"use server"

import { auth } from "@/lib/auth"
import { db } from "@/db"
import { customers } from "@/db/schema"
import { eq } from "drizzle-orm"
import { revalidatePath } from "next/cache"
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
  try {
    await db
      .update(customers)
      .set({ name: formData.get("name") as string })
      .where(eq(customers.id, id))

    revalidatePath("/admin/customers")
    return { success: true }
  } catch (error) {
    return { error: "저장 중 오류가 발생했습니다." }
  }
}
```

### Using Session on the Client

```typescript
// src/lib/auth-client.ts
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
})

export const { useSession, signIn, signOut } = authClient
```

```tsx
// 클라이언트 컴포넌트에서 사용
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

---

## Role-based Access Control (RBAC)

### User Type Definition

```typescript
// src/lib/types.ts
export type UserType = "admin" | "customer"

export interface User {
  id: string
  email: string
  name: string
  type: UserType
}
```

### Authorization Check Utilities

```typescript
// src/lib/auth-utils.ts
import { auth } from "./auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export async function requireAuth() {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    redirect("/login")
  }

  return session
}

export async function requireAdmin() {
  const session = await requireAuth()

  if (session.user.type !== "admin") {
    redirect("/unauthorized")
  }

  return session
}

export async function requireCustomer() {
  const session = await requireAuth()

  if (session.user.type !== "customer") {
    redirect("/unauthorized")
  }

  return session
}
```

> **Why extract `requireAuth`/`requireAdmin`?** 인증/권한 체크를 각 Server Action이나 페이지에서 직접 구현하면, 한 곳이라도 체크를 빠뜨리면 접근 제어 갭이 생김. 유틸리티로 추출하면 체크 로직이 단일 소스이고, 호출 누락 시 코드 리뷰에서 쉽게 발견 가능.

### Usage Examples

```typescript
// 페이지에서
export default async function AdminDashboard() {
  const session = await requireAdmin()

  return (
    <div>
      <h1>관리자 대시보드</h1>
      <p>환영합니다, {session.user.name}님</p>
    </div>
  )
}

// Server Action에서
export async function deleteCustomer(id: string) {
  const session = await requireAdmin()

  // 삭제 로직...
}
```

---

## Proxy (Route Protection)

> **Next.js 16**: `middleware.ts` has been deprecated and replaced by `proxy.ts`. The runtime also changed from Edge to **Node.js**, making DB access possible. However, it is recommended that the Proxy only handles lightweight route protection. Actual authentication verification should be performed in Server Components via `auth.api.getSession()`.

```typescript
// src/proxy.ts (Next.js 16 표준 파일 컨벤션)
import { NextRequest, NextResponse } from "next/server"

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Admin 경로 보호 (로그인 페이지 제외)
  if (pathname.startsWith("/admin") && !pathname.startsWith("/admin/login")) {
    // 세션 쿠키 존재 여부만 확인 (가벼운 검사)
    const sessionCookie = request.cookies.get("better-auth.session_token")
    if (!sessionCookie) {
      return NextResponse.redirect(new URL("/admin/login", request.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/admin/:path*"],
}
```

### Proxy vs Server Component Role Division

| Layer | Runtime | Role | Example |
|-------|---------|------|---------|
| Proxy (proxy.ts) | Node.js | Check cookie existence (fast redirect) | No session cookie --> `/admin/login` |
| Server Component (layout.tsx) | Node.js | Actual session verification + authorization check | `auth.api.getSession()` --> role verification |

> **Why not perform actual authentication in the Proxy?**
> Although the Proxy in Next.js 16 runs on the Node.js runtime and can access the DB, it executes at a network boundary separated from the render code. It is recommended not to rely on shared modules or global state, so only cookie existence is checked here while actual session validity verification is performed in Server Components. Lightweight defenses such as rate limiting can be added at this layer.

---

## Important Notes

1. **Session cookie name**: `better-auth.session_token`
2. **HTTPS required**: Always use HTTPS in production
3. **CSRF protection**: Handled automatically by Better Auth
4. **DB connection**: Connection pooling setup required when using the Drizzle adapter

### Reference Files

- Login/Signup implementation (LoginForm, Signup snippet): [`references/login-signup.md`](references/login-signup.md)
- Session refresh & expiration (SessionRefresher, SessionGuard): [`references/session-management.md`](references/session-management.md)
