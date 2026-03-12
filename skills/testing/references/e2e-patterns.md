# Playwright E2E Test Patterns

> Referenced from `testing/SKILL.md` — Page Object Pattern and E2E test examples.

## Page Object Pattern

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

## E2E Test Example

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
