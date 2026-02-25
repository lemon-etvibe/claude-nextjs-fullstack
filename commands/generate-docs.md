---
description: Auto-generate API and Server Action documentation
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# /generate-docs Command

Automatically generates documentation for Server Actions or API Routes.

## Usage

```
/generate-docs <file-path>
/generate-docs src/app/(admin)/_actions/customer.ts
/generate-docs src/app/api/files
```

## Server Action Documentation Template

```markdown
# {ActionName}

> {간단한 설명}

## 함수 시그니처

\`\`\`typescript
export async function actionName(
  id: string,
  prevState: unknown,
  formData: FormData
): Promise<ActionResult>
\`\`\`

## 파라미터

| 파라미터  | 타입     | 필수 | 설명                     |
| --------- | -------- | ---- | ------------------------ |
| id        | string   | O    | 리소스 ID                |
| prevState | unknown  | O    | useActionState 이전 상태 |
| formData  | FormData | O    | 폼 데이터                |

## FormData 필드

| 필드명    | 타입   | 필수 | 설명       |
| --------- | ------ | ---- | ---------- |
| name      | string | O    | 이름       |
| email     | string | O    | 이메일     |
| status    | string | X    | 상태       |

## 반환값

### 성공

\`\`\`typescript
{
  success: true,
  message?: string,
  data?: T
}
\`\`\`

### 에러

\`\`\`typescript
{
  error: string,
  details?: Record<string, string[]>  // 필드별 에러
}
\`\`\`

## 사용 예시

\`\`\`tsx
'use client'
import { useActionState } from 'react'
import { updateCustomer } from '../_actions/customer'

export function CustomerForm({ customerId }: { customerId: string }) {
  const [state, formAction, pending] = useActionState(
    updateCustomer.bind(null, customerId),
    null
  )

  return (
    <form action={formAction}>
      <input name="name" />
      <input name="email" type="email" />

      {state?.error && <p className="text-red-500">{state.error}</p>}

      <button disabled={pending}>
        {pending ? '저장 중...' : '저장'}
      </button>
    </form>
  )
}
\`\`\`

## 인증

- **필요 여부**: 필요
- **권한**: admin

## 캐시 무효화

- `revalidatePath('/admin/customers')`
```

## API Route Documentation Template

```markdown
# {API 이름}

> {간단한 설명}

## 엔드포인트

\`\`\`
{METHOD} /api/{path}
\`\`\`

## 요청

### Headers

| 헤더          | 필수 | 설명         |
| ------------- | ---- | ------------ |
| Authorization | O    | Bearer token |
| Content-Type  | O    | application/json |

### Body

\`\`\`typescript
interface RequestBody {
  field1: string
  field2?: number
}
\`\`\`

### Query Parameters

| 파라미터 | 타입   | 필수 | 설명 |
| -------- | ------ | ---- | ---- |
| page     | number | X    | 페이지 번호 |
| limit    | number | X    | 페이지당 개수 |

## 응답

### 200 OK

\`\`\`typescript
{
  data: T[],
  total: number,
  page: number
}
\`\`\`

### 400 Bad Request

\`\`\`typescript
{
  error: string,
  code: string
}
\`\`\`

### 401 Unauthorized

\`\`\`typescript
{
  error: "인증이 필요합니다."
}
\`\`\`

## 사용 예시

\`\`\`typescript
const response = await fetch('/api/path', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': \`Bearer \${token}\`
  },
  body: JSON.stringify({ field1: 'value' })
})

const data = await response.json()
\`\`\`
```

## Documentation Process

### 1. Code Analysis

- Extract function signatures
- Analyze parameter types
- Analyze return types
- Extract field information from Zod schemas

### 2. Context Identification

- Check authentication requirements
- Check cache invalidation
- Check error handling patterns

### 3. Document Generation

- Apply template
- Generate usage examples
- Save file

## Output Location

```
docs/
├── api/
│   └── {route-name}.md
└── actions/
    └── {action-name}.md
```

## Related Agents

This command is based on the `docs-writer` agent's documentation templates.

## Related Commands

- `/component-docs` - Generate component documentation
- `/update-changelog` - Update CHANGELOG
