---
name: testing
description: 테스트 패턴 가이드 - Vitest 단위 테스트, Testing Library 컴포넌트 테스트, Playwright E2E, Server Action 테스트
triggers:
  - 테스트
  - test
  - vitest
  - playwright
  - testing library
  - 단위 테스트
  - E2E
  - 컴포넌트 테스트
---

# 테스트 패턴

## 1. 테스트 전략 개요

### 테스팅 피라미드

| 레벨 | 도구 | 대상 | 속도 |
|------|------|------|------|
| Unit | Vitest | 유틸, Zod 스키마, Server Action | ⚡ 빠름 |
| Component | Testing Library | React 클라이언트 컴포넌트 | 🔶 보통 |
| E2E | Playwright | 전체 사용자 플로우 | 🐢 느림 |

> **원칙**: Unit 테스트를 가장 많이, E2E는 핵심 플로우만

### 파일 구조: Co-location

프로젝트의 `_actions/`, `_components/` co-location 원칙에 따라 테스트 파일도 소스 옆에 배치:

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

## 2. 환경 설정

### 패키지 설치

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

### package.json 스크립트

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

### 테스트 파일 격리 (프로덕션 보호)

`src/test/` 디렉토리의 mock 파일이 프로덕션 빌드에 포함되지 않도록:

1. **vitest.config.ts**의 `include`가 `src/**/*.test.{ts,tsx}`로 제한 (위 설정 참조)
2. **tsconfig.json** — 프로덕션 빌드용 별도 설정이 필요한 경우:

```json
{
  "exclude": ["node_modules", "src/test"]
}
```

> ⚠️ Next.js는 빌드 시 `src/test/` 내 파일을 라우트로 인식하지 않으므로 실질적 위험은 낮지만, 명시적 exclude가 안전합니다.

---

## 3. Server Action 테스트 패턴

프로젝트의 21개 Server Action이 동일한 패턴(auth → validation → DB → revalidate)을 따르므로 중앙 mock 설정을 사용합니다.

### 중앙 Mock 설정

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

### 테스트 헬퍼

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

### Server Action 테스트 템플릿

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

## 4. 단위 테스트 패턴

### 유틸 함수 테스트

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

### Zod 스키마 테스트

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

### 모킹 패턴

| 패턴 | 용도 | 예시 |
|------|------|------|
| `vi.mock("module")` | 모듈 전체 모킹 | `vi.mock("@/lib/prisma")` |
| `vi.fn()` | 함수 모킹 | `const onClick = vi.fn()` |
| `vi.spyOn(obj, "method")` | 기존 메서드 감시 | `vi.spyOn(console, "error")` |

> `vi.mock()`은 파일 최상위에서 호출해야 합니다 (호이스팅). 중앙 mock 파일(`src/test/mocks.ts`)을 import하면 자동 적용됩니다.

---

## 5. Testing Library 컴포넌트 테스트

### 기본 렌더링 테스트

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

### 폼 컴포넌트 테스트

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

### useActionState 컴포넌트 테스트

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

### 쿼리 우선순위

| 우선순위 | 쿼리 | 용도 |
|----------|------|------|
| 1 | `getByRole` | 버튼, 링크, 제목 등 |
| 2 | `getByLabelText` | 폼 필드 |
| 3 | `getByPlaceholderText` | placeholder 기반 |
| 4 | `getByText` | 텍스트 내용 |
| 5 | `getByTestId` | 최후 수단 (`data-testid`) |

---

## 6. Playwright E2E 테스트

### Page Object 패턴

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

### E2E 테스트 예시

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

## 7. 고급 패턴: MSW (Mock Service Worker)

외부 API를 호출하는 컴포넌트를 테스트할 때 사용합니다.

> **사용 시점**: Server Action은 `vi.mock()`으로 충분합니다. MSW는 `fetch`로 외부 API를 직접 호출하는 클라이언트 컴포넌트에 사용합니다.

### 핸들러 정의

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

### Vitest 통합

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

### 테스트 예시

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

## 8. 주의사항

> 파일 구조는 섹션 1 "파일 구조: Co-location" 참조

### 네이밍 규칙

| 파일 유형 | 패턴 | 위치 |
|-----------|------|------|
| 단위 테스트 | `*.test.ts` | 소스 옆 `__tests__/` |
| 컴포넌트 테스트 | `*.test.tsx` | 소스 옆 `__tests__/` |
| E2E 테스트 | `*.spec.ts` | `e2e/` 최상위 |
| Page Object | `*.page.ts` | `e2e/pages/` |
| 테스트 유틸 | `*.ts` | `src/test/` |

### 주의사항

1. **Server Components(RSC)는 직접 테스트 불가** — Testing Library는 클라이언트 환경. RSC의 데이터 로직은 Server Action이나 유틸로 분리하여 단위 테스트
2. **`vi.mock()`은 호이스팅됨** — 파일 최상위에서 호출 필수. 중앙 mock 파일을 import하면 자동 적용
3. **`vi.clearAllMocks()`** — 각 테스트 전에 mock 상태 초기화 (`beforeEach` 사용)
4. **FormData는 Node.js 18+ 내장** — Vitest 환경에서 별도 폴리필 불필요
5. **Playwright는 dev 서버 필요** — `playwright.config.ts`의 `webServer` 설정으로 자동 시작
6. **비동기 Server Action 테스트** — 항상 `await`으로 호출하고, `mockResolvedValue`/`mockRejectedValue` 사용
7. **Mock 파일 격리** — `src/test/` 디렉토리는 프로덕션 빌드에서 자동 제외되지만, `vitest.config.ts`의 `include` 패턴과 `tsconfig` `exclude`로 명시적 격리 권장
