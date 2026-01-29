---
name: refactor
description: 코드 리팩토링 제안 - 가독성, 유지보수성, 성능 개선
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /refactor 명령어

기존 코드의 리팩토링 방안을 분석하고 제안합니다.

## 사용법

```
/refactor <파일경로>
/refactor src/app/(admin)/_components/CustomerTable.tsx
```

## 리팩토링 관점

### 1. 코드 중복 제거

```typescript
// BEFORE: 중복 로직
const adminUsers = users.filter(u => u.role === 'admin')
const activeAdmins = adminUsers.filter(u => u.status === 'active')

// AFTER: 체이닝
const activeAdmins = users.filter(u =>
  u.role === 'admin' && u.status === 'active'
)
```

### 2. 컴포넌트 분리

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

### 3. Custom Hook 추출

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

### 4. 조건문 단순화

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

### 5. 타입 안전성 강화

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

### 6. 성능 최적화

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

## 리팩토링 원칙

### DO

- 작은 단위로 점진적 리팩토링
- 테스트 유지하며 변경
- 기능 변경 없이 구조만 개선
- 명확한 이름 사용

### DON'T

- 한 번에 대규모 변경
- 기능 추가와 리팩토링 동시 진행
- 과도한 추상화
- 성능 최적화 우선 (가독성이 먼저)

## 출력 형식

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

## 연계 명령어

- `/code-review` - 리팩토링 전 코드 품질 점검
- `/type-check` - 리팩토링 후 타입 검증
