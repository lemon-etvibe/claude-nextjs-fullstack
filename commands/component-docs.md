---
description: React 컴포넌트 Props 문서 자동 생성
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# /component-docs 명령어

React 컴포넌트의 Props와 사용법을 문서화합니다.

## 사용법

```
/component-docs <파일경로>
/component-docs src/components/ui/Button.tsx
/component-docs src/app/(admin)/_components/CustomerTable.tsx
```

## 컴포넌트 문서 템플릿

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

## 문서화 프로세스

### 1. 코드 분석

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

### 2. 추출 항목

- Props 인터페이스/타입
- 기본값 (defaultProps 또는 구조분해 기본값)
- JSDoc 주석
- 사용된 스타일 (Tailwind 클래스)

### 3. 문서 생성

- Props 테이블 생성
- 사용 예시 생성
- 변형 설명 추가

## Props 타입별 문서화

### Union 타입

```markdown
| variant | 'primary' \| 'secondary' \| 'destructive' | X | 'primary' | 버튼 스타일 |
```

### 함수 타입

```markdown
| onChange | (value: string) => void | O | - | 값 변경 시 호출 |
```

### 복잡한 객체

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

## 출력 위치

```
docs/
└── components/
    ├── ui/
    │   ├── Button.md
    │   └── Card.md
    └── sections/
        └── CustomerTable.md
```

## 연계 에이전트

이 명령어는 `docs-writer` 에이전트의 컴포넌트 문서 템플릿을 기반으로 합니다.

## 연계 명령어

- `/generate-docs` - API/Action 문서 생성
- `/update-changelog` - CHANGELOG 업데이트
