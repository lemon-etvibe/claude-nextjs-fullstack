# Session Refresh and Expiration Handling

> Referenced from `better-auth/SKILL.md` — client-side session refresh and expiration detection patterns.

## Client Session Refresh (SessionRefresher)

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

## Session Expiration Detection (SessionGuard)

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
