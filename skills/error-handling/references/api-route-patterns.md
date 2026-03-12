# API Route Patterns (Next.js 16 Route Handlers)

> Referenced from `error-handling/SKILL.md` — detailed patterns for API Route error handling.

## File Upload

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

## External Webhook

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

## External API Proxy

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

## SSE (Server-Sent Events)

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
