---
name: better-auth
description: Better Auth Authentication Pattern Guide - Session Management, Role-based Access Control, Server Action Integration
tested-with:
  enf: "0.9.1"
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
import { prismaAdapter } from "better-auth/adapters/prisma"
import { prisma } from "./prisma"

export const auth = betterAuth({
  database: prismaAdapter(prisma, {
    provider: "postgresql",
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

### Authentication in Server Action

```typescript
// src/app/(admin)/_actions/customer.ts
"use server"

import { auth } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
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
    await prisma.customer.update({
      where: { id },
      data: {
        name: formData.get("name") as string,
      },
    })

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

## Login / Signup Implementation

### Login Form

```tsx
"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { signIn } from "@/lib/auth-client"

export function LoginForm() {
  const router = useRouter()
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const formData = new FormData(e.currentTarget)
    const email = formData.get("email") as string
    const password = formData.get("password") as string

    const { error } = await signIn.email({
      email,
      password,
    })

    if (error) {
      setError(error.message || "로그인에 실패했습니다.")
      setLoading(false)
      return
    }

    router.push("/admin")
    router.refresh()
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="email">이메일</label>
        <input
          id="email"
          name="email"
          type="email"
          required
          autoComplete="email"
        />
      </div>

      <div>
        <label htmlFor="password">비밀번호</label>
        <input
          id="password"
          name="password"
          type="password"
          required
          autoComplete="current-password"
        />
      </div>

      {error && <p className="text-red-500">{error}</p>}

      <button type="submit" disabled={loading}>
        {loading ? "로그인 중..." : "로그인"}
      </button>
    </form>
  )
}
```

### Signup

```typescript
import { signUp } from "@/lib/auth-client"

const { error } = await signUp.email({
  email,
  password,
  name,
  // 추가 필드
  type: "customer",
})
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

## Session Refresh and Expiration Handling

### Client Session Refresh

```tsx
"use client"

import { useSession } from "@/lib/auth-client"
import { useEffect } from "react"

export function SessionRefresher() {
  const { data: session, refetch } = useSession()

  useEffect(() => {
    // 5분마다 세션 갱신
    const interval = setInterval(() => {
      refetch()
    }, 5 * 60 * 1000)

    return () => clearInterval(interval)
  }, [refetch])

  return null
}
```

### Session Expiration Detection

```tsx
"use client"

import { useSession } from "@/lib/auth-client"
import { useRouter } from "next/navigation"
import { useEffect } from "react"

export function SessionGuard({ children }: { children: React.ReactNode }) {
  const { data: session, isPending, error } = useSession()
  const router = useRouter()

  useEffect(() => {
    if (!isPending && !session) {
      router.push("/login?expired=true")
    }
  }, [session, isPending, router])

  if (isPending) return <LoadingScreen />
  if (!session) return null

  return <>{children}</>
}
```

---

## Important Notes

1. **Session cookie name**: `better-auth.session_token`
2. **HTTPS required**: Always use HTTPS in production
3. **CSRF protection**: Handled automatically by Better Auth
4. **DB connection**: Connection pooling setup required when using the Prisma adapter
