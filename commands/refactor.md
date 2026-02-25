---
description: Code refactoring suggestions - readability, maintainability, and performance improvements
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /refactor Command

Analyzes existing code and suggests refactoring approaches.

## Usage

```
/refactor <file-path>
/refactor src/app/(admin)/_components/CustomerTable.tsx
```

## Refactoring Perspectives

### 1. Eliminate Code Duplication

```typescript
// BEFORE: 중복 로직
const adminUsers = users.filter(u => u.role === 'admin')
const activeAdmins = adminUsers.filter(u => u.status === 'active')

// AFTER: 체이닝
const activeAdmins = users.filter(u =>
  u.role === 'admin' && u.status === 'active'
)
```

### 2. Component Decomposition

```tsx
// BEFORE: 거대한 컴포넌트 (200+ lines)
function CustomerPage() {
  // 상태, 핸들러, UI 모두 포함
}

// AFTER: 책임 분리
function CustomerPage() {
  return (
    <CustomerProvider>
      <CustomerHeader />
      <CustomerTable />
      <CustomerPagination />
    </CustomerProvider>
  )
}
```

### 3. Custom Hook Extraction

```typescript
// BEFORE: 컴포넌트에 로직 혼재
function CustomerList() {
  const [customers, setCustomers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchCustomers()
      .then(setCustomers)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [])

  // UI...
}

// AFTER: 훅 분리
function useCustomers() {
  const [customers, setCustomers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => { /* ... */ }, [])

  return { customers, loading, error }
}

function CustomerList() {
  const { customers, loading, error } = useCustomers()
  // UI만 담당
}
```

### 4. Simplify Conditionals

```typescript
// BEFORE: 중첩 조건
if (user) {
  if (user.isAdmin) {
    if (user.isActive) {
      // do something
    }
  }
}

// AFTER: Early return
if (!user) return null
if (!user.isAdmin) return <Unauthorized />
if (!user.isActive) return <Inactive />

// do something
```

### 5. Strengthen Type Safety

```typescript
// BEFORE: any 타입
function processData(data: any) {
  return data.items.map((item: any) => item.name)
}

// AFTER: 명시적 타입
interface DataResponse {
  items: Array<{ id: string; name: string }>
}

function processData(data: DataResponse) {
  return data.items.map(item => item.name)
}
```

### 6. Performance Optimization

```typescript
// BEFORE: 불필요한 리렌더
function Parent({ items }) {
  const handleClick = (id) => { /* ... */ }
  return items.map(item => (
    <Child key={item.id} onClick={() => handleClick(item.id)} />
  ))
}

// AFTER: 메모이제이션
function Parent({ items }) {
  const handleClick = useCallback((id) => { /* ... */ }, [])
  return items.map(item => (
    <Child key={item.id} id={item.id} onClick={handleClick} />
  ))
}
```

## Refactoring Principles

### DO

- Refactor incrementally in small units
- Maintain tests while making changes
- Improve structure without changing functionality
- Use clear naming

### DON'T

- Make large-scale changes all at once
- Add features and refactor simultaneously
- Over-abstract
- Prioritize performance over readability

## Output Format

```markdown
## 리팩토링 제안: {파일명}

### 현재 코드 분석
- 총 라인: N줄
- 컴포넌트/함수 수: N개
- 복잡도 평가: 높음/중간/낮음

### 리팩토링 제안

#### 1. {제안 제목}

**현재 코드** (라인 N-M):
```typescript
// 현재 코드
```

**개선 코드**:
```typescript
// 개선된 코드
```

**효과**: 가독성 향상, 재사용성 증가 등

#### 2. {제안 제목}
...

### 리팩토링 순서
1. ...
2. ...

### 주의사항
- ...
```

## Related Commands

- `/code-review` - Code quality review before refactoring
- `/type-check` - Type verification after refactoring
