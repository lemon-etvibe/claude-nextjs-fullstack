# Component Test Patterns (Testing Library)

> Referenced from `testing/SKILL.md` — detailed component test patterns.

## Basic Rendering Test

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

## Form Component Test

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

## useActionState Component Test

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

## Query Priority

| Priority | Query | Usage |
|----------|-------|-------|
| 1 | `getByRole` | Buttons, links, headings, etc. |
| 2 | `getByLabelText` | Form fields |
| 3 | `getByPlaceholderText` | Placeholder-based |
| 4 | `getByText` | Text content |
| 5 | `getByTestId` | Last resort (`data-testid`) |
