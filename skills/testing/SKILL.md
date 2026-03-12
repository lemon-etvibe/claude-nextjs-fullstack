---
name: testing
description: Testing patterns — ALWAYS use when writing or modifying tests. Covers Vitest unit tests, Testing Library component tests, Playwright E2E, and Server Action test templates.
tested-with:
  enf: "1.1.0"
  next: "16.x"
  react: "19.x"
  drizzle-orm: "0.45.x"
  typescript: "5.x"
triggers:
  - 테스트
  - test
  - vitest
  - playwright
  - testing library
  - 단위 테스트
  - E2E
  - 컴포넌트 테스트
  - unit test
  - component test
---

# Testing Patterns

## 1. Testing Strategy Overview

### Testing Pyramid

| Level | Tool | Target | Speed |
|-------|------|--------|-------|
| Unit | Vitest | Utilities, Zod schemas, Server Actions | Fast |
| Component | Testing Library | React client components | Medium |
| E2E | Playwright | Full user flows | Slow |

> **Principle**: Write the most unit tests; E2E only for critical flows.
>
> **Why this pyramid?** Unit 테스트는 빠르고 유지비용이 낮아 신뢰도 대비 비용이 최적. E2E는 실제 사용자 흐름을 검증하지만 느리고 깨지기 쉬워서 핵심 플로우에만 집중해야 전체 테스트 스위트의 실행 시간과 유지보수 부담을 관리할 수 있음.

### File Structure: Co-location

Following the project's `_actions/`, `_components/` co-location principle, test files are also placed next to their source:

```
src/app/(admin)/
├── _actions/
│   ├── customer.ts
│   └── __tests__/
│       └── customer.test.ts
├── _components/
│   ├── CustomerTable.tsx
│   └── __tests__/
│       └── CustomerTable.test.tsx
e2e/                              # E2E는 최상위 (여러 페이지 횡단)
├── login.spec.ts
└── pages/
    └── login.page.ts
```

---

## 2. Environment Setup

### Package Installation

```bash
# Unit + Component 테스트
pnpm add -D vitest @vitejs/plugin-react jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event

# E2E 테스트
pnpm add -D @playwright/test
pnpm exec playwright install chromium

# (선택) 외부 API 모킹
pnpm add -D msw
```

### vitest.config.ts

```typescript
import { defineConfig } from "vitest/config"
import react from "@vitejs/plugin-react"
import path from "path"

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src"),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["src/test/setup.ts"],
    include: ["src/**/*.test.{ts,tsx}"],
    coverage: {
      provider: "istanbul",
      reporter: ["text", "html"],
      include: ["src/**/*.{ts,tsx}"],
      exclude: ["src/test/**", "src/generated/**"],
    },
  },
})
```

### playwright.config.ts

```typescript
import { defineConfig, devices } from "@playwright/test"

export default defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  webServer: {
    command: "pnpm dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
  ],
})
```

### src/test/setup.ts

```typescript
import "@testing-library/jest-dom/vitest"
```

### package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

### Test File Isolation (Production Protection)

To prevent mock files in `src/test/` from being included in the production build:

1. **vitest.config.ts** `include` is restricted to `src/**/*.test.{ts,tsx}` (see config above)
2. **tsconfig.json** -- if a separate production build config is needed:

```json
{
  "exclude": ["node_modules", "src/test"]
}
```

> Note: Next.js does not recognize files in `src/test/` as routes during build, so the practical risk is low, but an explicit exclude is safer.

---

## 3. Server Action Test Patterns

Since the project's 21 Server Actions follow the same pattern (auth --> validation --> DB --> revalidate), a centralized mock setup is used.

> **Why centralized mocks?** 21개 Server Action이 동일한 의존성(auth, db, headers, revalidatePath)을 사용하므로, 각 테스트 파일마다 mock을 중복 정의하면 의존성 변경 시 21곳을 모두 수정해야 함. 중앙화하면 mock 정의가 1곳이라 유지보수가 O(1).

### Centralized Mock Setup

```typescript
// src/test/mocks.ts
import { vi } from "vitest"

// --- Better Auth ---
export const mockGetSession = vi.fn()

vi.mock("@/lib/auth", () => ({
  auth: {
    api: {
      getSession: (...args: unknown[]) => mockGetSession(...args),
    },
  },
}))

// --- Drizzle (DB mock — 체이닝 메서드 mock) ---
export const mockDb = {
  select: vi.fn().mockReturnThis(),
  from: vi.fn().mockReturnThis(),
  where: vi.fn().mockReturnThis(),
  insert: vi.fn().mockReturnThis(),
  values: vi.fn().mockReturnThis(),
  update: vi.fn().mockReturnThis(),
  set: vi.fn().mockReturnThis(),
  delete: vi.fn().mockReturnThis(),
  returning: vi.fn(),
  query: {
    customers: { findMany: vi.fn(), findFirst: vi.fn() },
    campaigns: { findMany: vi.fn(), findFirst: vi.fn() },
  },
  transaction: vi.fn(),
}

vi.mock("@/db", () => ({
  db: mockDb,
}))

// --- Next.js ---
export const mockHeaders = vi.fn(() => new Headers())
vi.mock("next/headers", () => ({
  headers: () => mockHeaders(),
}))

export const mockRevalidatePath = vi.fn()
vi.mock("next/cache", () => ({
  revalidatePath: (...args: unknown[]) => mockRevalidatePath(...args),
}))
```

### Test Helpers

```typescript
// src/test/helpers.ts
export function createFormData(data: Record<string, string>): FormData {
  const fd = new FormData()
  Object.entries(data).forEach(([k, v]) => fd.append(k, v))
  return fd
}

export function mockSession(overrides?: Record<string, unknown>) {
  return {
    user: { id: "test-user-id", name: "테스트 관리자", email: "admin@test.com", type: "admin", ...overrides },
    session: { id: "test-session-id", expiresAt: new Date(Date.now() + 86400000) },
  }
}
```

### Server Action Test Template

```typescript
// src/app/(admin)/_actions/__tests__/customer.test.ts
import { describe, it, expect, beforeEach } from "vitest"
import {
  mockGetSession,
  mockDb,
  mockRevalidatePath,
} from "@/test/mocks"
import { createFormData, mockSession } from "@/test/helpers"
import { updateCustomer } from "../customer"

describe("updateCustomer", () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it("인증되지 않은 사용자 → 에러 반환", async () => {
    mockGetSession.mockResolvedValue(null)

    const formData = createFormData({ name: "홍길동" })
    const result = await updateCustomer("id-1", undefined, formData)

    expect(result).toEqual({ error: "인증이 필요합니다." })
    expect(mockDb.update).not.toHaveBeenCalled()
  })

  it("유효하지 않은 데이터 → 에러 반환", async () => {
    mockGetSession.mockResolvedValue(mockSession())

    const formData = createFormData({ name: "" }) // 빈 이름
    const result = await updateCustomer("id-1", undefined, formData)

    expect(result).toHaveProperty("error")
  })

  it("정상 업데이트 → success + revalidatePath", async () => {
    mockGetSession.mockResolvedValue(mockSession())
    mockDb.returning.mockResolvedValue([{ id: "id-1", name: "홍길동" }])

    const formData = createFormData({ name: "홍길동" })
    const result = await updateCustomer("id-1", undefined, formData)

    expect(result).toEqual({ success: true })
    expect(mockDb.update).toHaveBeenCalled()
    expect(mockRevalidatePath).toHaveBeenCalledWith("/admin/customers")
  })

  it("DB 에러 → 에러 반환", async () => {
    mockGetSession.mockResolvedValue(mockSession())
    mockDb.returning.mockRejectedValue(new Error("DB 연결 실패"))

    const formData = createFormData({ name: "홍길동" })
    const result = await updateCustomer("id-1", undefined, formData)

    expect(result).toHaveProperty("error")
  })
})
```

---

## 4. Unit Test Patterns

### Utility Function Tests

```typescript
// src/lib/__tests__/format.test.ts
import { describe, it, expect } from "vitest"
import { formatCurrency, formatDate } from "../format"

describe("formatCurrency", () => {
  it("한국 원화 형식으로 포맷", () => {
    expect(formatCurrency(1000000)).toBe("1,000,000원")
  })

  it("0원 처리", () => {
    expect(formatCurrency(0)).toBe("0원")
  })
})
```

### Zod Schema Tests

```typescript
// src/app/(admin)/_lib/__tests__/schemas.test.ts
import { describe, it, expect } from "vitest"
import { customerSchema } from "../schemas"

describe("customerSchema", () => {
  it("유효한 데이터 통과", () => {
    expect(customerSchema.safeParse({ name: "홍길동", email: "hong@test.com" }).success).toBe(true)
  })

  it("이메일 형식 오류", () => {
    const result = customerSchema.safeParse({ name: "홍길동", email: "not-email" })
    expect(result.success).toBe(false)
  })
})
```

### Mocking Patterns

| Pattern | Usage | Example |
|---------|-------|---------|
| `vi.mock("module")` | Mock entire module | `vi.mock("@/db")` |
| `vi.fn()` | Mock function | `const onClick = vi.fn()` |
| `vi.spyOn(obj, "method")` | Spy on existing method | `vi.spyOn(console, "error")` |

> `vi.mock()` must be called at the top level of the file (hoisting). Importing the centralized mock file (`src/test/mocks.ts`) applies mocks automatically.

---

## 5. Important Notes

> For file structure, see Section 1 "File Structure: Co-location"

### Naming Rules

| File Type | Pattern | Location |
|-----------|---------|----------|
| Unit test | `*.test.ts` | `__tests__/` next to source |
| Component test | `*.test.tsx` | `__tests__/` next to source |
| E2E test | `*.spec.ts` | Top-level `e2e/` |
| Page Object | `*.page.ts` | `e2e/pages/` |
| Test utilities | `*.ts` | `src/test/` |

### Important Notes

1. **Server Components (RSC) cannot be tested directly** -- Testing Library runs in a client environment. Extract RSC data logic into Server Actions or utilities for unit testing
2. **`vi.mock()` is hoisted** -- must be called at the file top level. Importing the centralized mock file applies mocks automatically
3. **`vi.clearAllMocks()`** -- reset mock state before each test (use `beforeEach`)
4. **FormData is built into Node.js 18+** -- no separate polyfill needed in the Vitest environment
5. **Playwright requires a dev server** -- auto-started via the `webServer` setting in `playwright.config.ts`
6. **Async Server Action tests** -- always call with `await` and use `mockResolvedValue`/`mockRejectedValue`
7. **Mock file isolation** -- `src/test/` is automatically excluded from production builds, but explicit isolation via `vitest.config.ts` `include` patterns and `tsconfig` `exclude` is recommended

### Reference Files

- Component tests (Basic Rendering, Form, useActionState, Query Priority): [`references/component-tests.md`](references/component-tests.md)
- E2E patterns (Page Object Pattern, E2E Test Example): [`references/e2e-patterns.md`](references/e2e-patterns.md)
- MSW patterns (Handler Definition, Vitest Integration, Test Example): [`references/msw-patterns.md`](references/msw-patterns.md)
