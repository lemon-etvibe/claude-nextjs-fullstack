# Login / Signup Implementation

> Referenced from `better-auth/SKILL.md` — detailed login form and signup patterns.

## Login Form

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

## Signup

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
