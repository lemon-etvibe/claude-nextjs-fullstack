---
description: Auto-generate React component Props documentation
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# /component-docs Command

Documents React component Props and usage.

## Usage

```
/component-docs <file-path>
/component-docs src/components/ui/Button.tsx
/component-docs src/app/(admin)/_components/CustomerTable.tsx
```

## Component Documentation Template

```markdown
# {ComponentName}

> {컴포넌트 설명}

## 미리보기

{사용 예시 이미지 또는 설명}

## Props

| Prop | 타입 | 필수 | 기본값 | 설명 |
| ---- | ---- | ---- | ------ | ---- |
| variant | 'primary' \| 'secondary' | X | 'primary' | 버튼 스타일 |
| size | 'sm' \| 'md' \| 'lg' | X | 'md' | 버튼 크기 |
| disabled | boolean | X | false | 비활성화 상태 |
| onClick | () => void | X | - | 클릭 핸들러 |
| children | ReactNode | O | - | 버튼 내용 |

## 사용 예시

### 기본 사용

\`\`\`tsx
import { Button } from '@/components/ui/Button'

<Button variant="primary" size="md">
  저장하기
</Button>
\`\`\`

### 비활성화

\`\`\`tsx
<Button disabled>
  처리 중...
</Button>
\`\`\`

### 아이콘과 함께

\`\`\`tsx
import Plus from 'lucide-react/dist/esm/icons/plus'

<Button>
  <Plus className="w-4 h-4 mr-2" />
  추가하기
</Button>
\`\`\`

## 변형 (Variants)

### Primary

기본 스타일. 주요 액션에 사용.

### Secondary

보조 스타일. 덜 중요한 액션에 사용.

### Destructive

위험한 액션 (삭제 등)에 사용.

## 접근성

- 키보드 네비게이션 지원 (Tab, Enter, Space)
- disabled 상태에서 aria-disabled 적용
- 스크린 리더 호환

## 관련 컴포넌트

- `IconButton` - 아이콘만 있는 버튼
- `ButtonGroup` - 버튼 그룹
- `LoadingButton` - 로딩 상태 버튼
```

## Documentation Process

### 1. Code Analysis

```typescript
// 분석 대상
interface ButtonProps {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  onClick?: () => void
  children: React.ReactNode
}
```

### 2. Extracted Items

- Props interface/types
- Default values (defaultProps or destructuring defaults)
- JSDoc comments
- Styles used (Tailwind classes)

### 3. Document Generation

- Generate Props table
- Generate usage examples
- Add variant descriptions

## Props Documentation by Type

### Union Types

```markdown
| variant | 'primary' \| 'secondary' \| 'destructive' | X | 'primary' | 버튼 스타일 |
```

### Function Types

```markdown
| onChange | (value: string) => void | O | - | 값 변경 시 호출 |
```

### Complex Objects

```markdown
| config | `CustomerConfig` | O | - | 설정 객체 (하단 참조) |

### CustomerConfig

\`\`\`typescript
interface CustomerConfig {
  columns: string[]
  sortable: boolean
  filterable: boolean
}
\`\`\`
```

## Output Location

```
docs/
└── components/
    ├── ui/
    │   ├── Button.md
    │   └── Card.md
    └── sections/
        └── CustomerTable.md
```

## Related Agents

This command is based on the `docs-writer` agent's component documentation template.

## Related Commands

- `/generate-docs` - Generate API/Action documentation
- `/update-changelog` - Update CHANGELOG
