# MSW (Mock Service Worker) Patterns

> Referenced from `testing/SKILL.md` — used when testing components that call external APIs.
>
> **When to use**: `vi.mock()` is sufficient for Server Actions. MSW is used for client components that directly call external APIs via `fetch`.

## Handler Definition

```typescript
// src/test/handlers.ts
import { http, HttpResponse } from "msw"

export const handlers = [
  http.get("/api/customers", () => {
    return HttpResponse.json([
      { id: "1", name: "홍길동", email: "hong@test.com" },
      { id: "2", name: "김철수", email: "kim@test.com" },
    ])
  }),

  http.post("/api/customers", async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: "3", ...body }, { status: 201 })
  }),
]
```

## Vitest Integration

```typescript
// src/test/server.ts
import { setupServer } from "msw/node"
import { handlers } from "./handlers"
export const server = setupServer(...handlers)

// src/test/setup.ts (기존 파일에 MSW 추가)
import "@testing-library/jest-dom/vitest"
import { server } from "./server"
import { afterAll, afterEach, beforeAll } from "vitest"
beforeAll(() => server.listen({ onUnhandledRequest: "error" }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

## Test Example

```tsx
import { render, screen } from "@testing-library/react"
import { CustomerList } from "../CustomerList"

it("API에서 고객 목록을 가져와 표시", async () => {
  render(<CustomerList />)
  // MSW가 /api/customers 응답을 자동 모킹
  expect(await screen.findByText("홍길동")).toBeInTheDocument()
})
```
