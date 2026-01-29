---
name: type-check
description: TypeScript 타입 검증 - strict 모드 준수, 타입 안전성 점검
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /type-check 명령어

TypeScript 타입 검사를 수행하고 타입 관련 이슈를 분석합니다.

## 사용법

```
/type-check                     # 전체 프로젝트 검사
/type-check <파일경로>          # 특정 파일 분석
```

## 검사 단계

### 1. tsc 실행

```bash
pnpm tsc --noEmit
```

에러 발생 시 각 에러를 분석하고 해결 방안을 제시합니다.

### 2. 타입 안전성 검사

#### any 타입 사용

```typescript
// BAD
function processData(data: any) { ... }

// GOOD: unknown + 타입 가드
function processData(data: unknown) {
  if (isValidData(data)) { ... }
}

// GOOD: 명시적 타입
interface DataType { ... }
function processData(data: DataType) { ... }
```

#### 타입 단언 남용

```typescript
// BAD: 무분별한 단언
const user = data as User

// GOOD: 타입 가드
function isUser(data: unknown): data is User {
  return typeof data === 'object' && data !== null && 'id' in data
}

if (isUser(data)) {
  // data는 User 타입
}
```

#### Non-null 단언

```typescript
// BAD: 위험한 !
const value = obj.prop!

// GOOD: 옵셔널 체이닝 + 기본값
const value = obj?.prop ?? defaultValue

// GOOD: 명시적 체크
if (obj.prop !== undefined) {
  const value = obj.prop
}
```

### 3. Strict 모드 준수

tsconfig.json 설정:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### 4. 제네릭 활용

```typescript
// BEFORE: 반복되는 타입
function getFirst(items: string[]): string | undefined
function getFirst(items: number[]): number | undefined

// AFTER: 제네릭
function getFirst<T>(items: T[]): T | undefined {
  return items[0]
}
```

### 5. 유틸리티 타입 활용

```typescript
// Partial - 모든 속성 선택적
type UpdateUser = Partial<User>

// Pick - 특정 속성만 선택
type UserSummary = Pick<User, 'id' | 'name'>

// Omit - 특정 속성 제외
type CreateUser = Omit<User, 'id' | 'createdAt'>

// Record - 키-값 매핑
type StatusMap = Record<Status, string>
```

## 일반적인 타입 에러와 해결

### 1. 'X' is possibly 'undefined'

```typescript
// 에러
const name = user.profile.name // profile이 undefined일 수 있음

// 해결 1: 옵셔널 체이닝
const name = user.profile?.name ?? 'Unknown'

// 해결 2: 조건 체크
if (user.profile) {
  const name = user.profile.name
}
```

### 2. Type 'X' is not assignable to type 'Y'

```typescript
// 에러
const status: 'active' | 'inactive' = someString

// 해결: 타입 가드 또는 검증
const status = isValidStatus(someString) ? someString : 'inactive'
```

### 3. Property 'X' does not exist on type 'Y'

```typescript
// 에러: 동적 속성 접근
const value = obj[key] // key의 타입이 불확실

// 해결: keyof 사용
function getValue<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}
```

## 출력 형식

```markdown
## TypeScript 검사 결과

### tsc 실행 결과
- 총 에러: N개
- 총 경고: N개

### 에러 분석

#### 1. {에러 메시지}
- **파일**: path/to/file.ts:N
- **원인**: ...
- **해결 방안**:
```typescript
// 수정 코드
```

### 타입 안전성 이슈

#### any 타입 사용 (N건)
| 파일 | 라인 | 코드 |
| ---- | ---- | ---- |

#### 타입 단언 (N건)
| 파일 | 라인 | 코드 |
| ---- | ---- | ---- |

### 개선 권장사항
1. ...
2. ...
```

## 연계 명령어

- `/code-review` - 전체 코드 품질 검사
- `/refactor` - 타입 관련 리팩토링 제안
