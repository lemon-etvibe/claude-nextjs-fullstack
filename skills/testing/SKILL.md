---
name: testing
description: Testing Pattern Guide - Vitest Unit Tests, Testing Library Component Tests, Playwright E2E, Server Action Tests
tested-with:
  enf: "0.9.1"
  next: "16.x"
  react: "19.x"
  prisma: "7.x"
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

> **Principle**: Write the most unit tests; E2E only for critical flows

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

// --- Prisma (모델별 CRUD mock — 필요한 모델만 추가) ---
export const mockPrisma = {
  customer: { findMany: vi.fn(), findUnique: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
  campaign: { findMany: vi.fn(), findUnique: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
}

vi.mock("@/lib/prisma", () => ({
  default: mockPrisma,
  prisma: mockPrisma,
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
  mockPrisma,
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
    expect(mockPrisma.customer.update).not.toHaveBeenCalled()
  })

  it("유효하지 않은 데이터 → 에러 반환", async () => {
    mockGetSession.mockResolvedValue(mockSession())

    const formData = createFormData({ name: "" }) // 빈 이름
    const result = await updateCustomer("id-1", undefined, formData)

    expect(result).toHaveProperty("error")
  })

  it("정상 업데이트 → success + revalidatePath", async () => {
    mockGetSession.mockResolvedValue(mockSession())
    mockPrisma.customer.update.mockResolvedValue({ id: "id-1", name: "홍길동" })

    const formData = createFormData({ name: "홍길동" })
    const result = await updateCustomer("id-1", undefined, formData)

    expect(result).toEqual({ success: true })
    expect(mockPrisma.customer.update).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: "id-1" } })
    )
    expect(mockRevalidatePath).toHaveBeenCalledWith("/admin/customers")
  })

  it("DB 에러 → 에러 반환", async () => {
    mockGetSession.mockResolvedValue(mockSession())
    mockPrisma.customer.update.mockRejectedValue(new Error("DB 연결 실패"))

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
| `vi.mock("module")` | Mock entire module | `vi.mock("@/lib/prisma")` |
| `vi.fn()` | Mock function | `const onClick = vi.fn()` |
| `vi.spyOn(obj, "method")` | Spy on existing method | `vi.spyOn(console, "error")` |

> `vi.mock()` must be called at the top level of the file (hoisting). Importing the centralized mock file (`src/test/mocks.ts`) applies mocks automatically.

---

## 5. Testing Library Component Tests

### Basic Rendering Test

```tsx
// src/app/(admin)/_components/__tests__/CustomerCard.test.tsx
import { render, screen } from "@testing-library/react"
import { CustomerCard } from "../CustomerCard"

it("고객 이름과 이메일을 표시", () => {
  render(<CustomerCard customer={{ id: "1", name: "홍길동", email: "hong@test.com" }} />)
  expect(screen.getByText("홍길동")).toBeInTheDocument()
  expect(screen.getByText("hong@test.com")).toBeInTheDocument()
})
```

### Form Component Test

```tsx
// src/app/(admin)/_components/__tests__/CustomerForm.test.tsx
import { describe, it, expect, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { CustomerForm } from "../CustomerForm"

describe("CustomerForm", () => {
  it("입력 후 제출 시 폼 데이터 전달", async () => {
    const user = userEvent.setup()
    const mockAction = vi.fn()

    render(<CustomerForm action={mockAction} />)

    await user.type(screen.getByLabelText("이름"), "홍길동")
    await user.type(screen.getByLabelText("이메일"), "hong@test.com")
    await user.click(screen.getByRole("button", { name: "저장" }))

    expect(mockAction).toHaveBeenCalled()
  })

  it("필수 필드 미입력 시 에러 메시지 표시", async () => {
    const user = userEvent.setup()

    render(<CustomerForm action={vi.fn()} />)

    await user.click(screen.getByRole("button", { name: "저장" }))

    expect(screen.getByText(/필수/)).toBeInTheDocument()
  })
})
```

### useActionState Component Test

```tsx
// Server Action을 사용하는 폼 컴포넌트 테스트
import { describe, it, expect, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"

// Server Action을 모킹
vi.mock("../_actions/customer", () => ({
  updateCustomer: vi.fn(),
}))

import { CustomerEditForm } from "../CustomerEditForm"
import { updateCustomer } from "../_actions/customer"

describe("CustomerEditForm", () => {
  it("에러 상태 표시", async () => {
    vi.mocked(updateCustomer).mockResolvedValue({
      error: "이름은 필수입니다.",
    })

    render(
      <CustomerEditForm
        customer={{ id: "1", name: "홍길동", email: "hong@test.com" }}
      />
    )

    // 폼 제출 시뮬레이션 후 에러 메시지 확인
    const user = userEvent.setup()
    await user.click(screen.getByRole("button", { name: /저장/ }))

    // useActionState를 통해 에러가 표시되는지 확인
    expect(await screen.findByText("이름은 필수입니다.")).toBeInTheDocument()
  })
})
```

### Query Priority

| Priority | Query | Usage |
|----------|-------|-------|
| 1 | `getByRole` | Buttons, links, headings, etc. |
| 2 | `getByLabelText` | Form fields |
| 3 | `getByPlaceholderText` | Placeholder-based |
| 4 | `getByText` | Text content |
| 5 | `getByTestId` | Last resort (`data-testid`) |

---

## 6. Playwright E2E Tests

### Page Object Pattern

```typescript
// e2e/pages/login.page.ts
import type { Page } from "@playwright/test"

export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto("/admin/login")
  }

  async login(email: string, password: string) {
    await this.page.getByLabel("이메일").fill(email)
    await this.page.getByLabel("비밀번호").fill(password)
    await this.page.getByRole("button", { name: "로그인" }).click()
  }

  async getErrorMessage() {
    return this.page.getByRole("alert").textContent()
  }
}
```

### E2E Test Example

```typescript
// e2e/login.spec.ts
import { test, expect } from "@playwright/test"
import { LoginPage } from "./pages/login.page"

test.describe("관리자 로그인", () => {
  let loginPage: LoginPage

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page)
    await loginPage.goto()
  })

  test("올바른 자격 증명으로 로그인 성공", async ({ page }) => {
    await loginPage.login("admin@test.com", "password123")
    await expect(page).toHaveURL("/admin/dashboard")
  })

  test("잘못된 비밀번호로 에러 메시지 표시", async () => {
    await loginPage.login("admin@test.com", "wrong-password")
    const error = await loginPage.getErrorMessage()
    expect(error).toContain("비밀번호")
  })
})
```

---

## 7. Advanced Pattern: MSW (Mock Service Worker)

Used when testing components that call external APIs.

> **When to use**: `vi.mock()` is sufficient for Server Actions. MSW is used for client components that directly call external APIs via `fetch`.

### Handler Definition

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

### Vitest Integration

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

### Test Example

```tsx
import { render, screen } from "@testing-library/react"
import { CustomerList } from "../CustomerList"

it("API에서 고객 목록을 가져와 표시", async () => {
  render(<CustomerList />)
  // MSW가 /api/customers 응답을 자동 모킹
  expect(await screen.findByText("홍길동")).toBeInTheDocument()
})
```

---

## 8. Important Notes

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
