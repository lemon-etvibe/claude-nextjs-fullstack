---
description: Promise.all optimization check - find sequential await patterns and suggest parallelization
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /waterfall-check Command

Finds sequential await patterns (waterfall) in code and suggests Promise.all() parallelization.

## Usage

```
/waterfall-check                    # 전체 프로젝트 검사
/waterfall-check <file-path>        # 특정 파일 검사
/waterfall-check src/app/(admin)    # 특정 디렉토리 검사
```

## What is the Waterfall Problem?

Independent async operations executed sequentially unnecessarily increase total execution time.

```typescript
// BAD: Waterfall (총 650ms = 200 + 250 + 200)
const customer = await fetchCustomer(id)    // 200ms
const campaigns = await fetchCampaigns(id)  // 250ms
const stats = await fetchStats(id)          // 200ms

// GOOD: Parallel (총 250ms = max(200, 250, 200))
const [customer, campaigns, stats] = await Promise.all([
  fetchCustomer(id),    // 200ms
  fetchCampaigns(id),   // 250ms
  fetchStats(id),       // 200ms
])
```

## Check Criteria

### 1. Consecutive await Statements (3 or more)

```typescript
// DETECTED: 3개 이상 연속 await
const a = await fetchA()
const b = await fetchB()
const c = await fetchC()
```

### 2. Independence Analysis

```typescript
// 독립적 (병렬화 가능)
const user = await fetchUser(id)
const posts = await fetchPosts(id)

// 의존적 (순차 필요)
const user = await fetchUser(id)
const profile = await fetchProfile(user.profileId) // user 필요
```

### 3. Server Component Data Fetching

```typescript
// Page 또는 Server Component의 async 함수
async function CustomerPage({ params }) {
  const { id } = await params

  // 검사 대상
  const customer = await prisma.customer.findUnique(...)
  const campaigns = await prisma.campaign.findMany(...)
}
```

## Optimization Patterns

### 1. Promise.all (all must succeed)

```typescript
const [customer, campaigns, stats] = await Promise.all([
  fetchCustomer(id),
  fetchCampaigns(id),
  fetchStats(id),
])
```

### 2. Promise.allSettled (partial failure allowed)

```typescript
const results = await Promise.allSettled([
  fetchCustomer(id),
  fetchCampaigns(id),
  fetchOptionalData(id), // 실패해도 OK
])

const [customer, campaigns, optional] = results.map(r =>
  r.status === 'fulfilled' ? r.value : null
)
```

### 3. Partial Parallelization (with dependencies)

```typescript
// 먼저 병렬 실행
const [customer, campaigns] = await Promise.all([
  fetchCustomer(id),
  fetchCampaigns(id),
])

// 의존적인 요청은 이후 실행
const orders = await fetchOrders(customer.customerId)
```

### 4. Suspense Boundary Utilization (RSC)

```tsx
// 각 섹션이 독립적으로 스트리밍
export default function CustomerPage({ params }) {
  return (
    <div className="grid grid-cols-2 gap-4">
      <Suspense fallback={<CustomerSkeleton />}>
        <CustomerSection id={params.id} />
      </Suspense>
      <Suspense fallback={<CampaignsSkeleton />}>
        <CampaignsSection id={params.id} />
      </Suspense>
    </div>
  )
}
```

## Output Format

```markdown
## Waterfall 검사 결과

### 발견된 패턴

#### 1. {파일경로}:{라인}

**현재 코드**:
```typescript
const a = await fetchA(id)
const b = await fetchB(id)
const c = await fetchC(id)
```

**분석**:
- 예상 순차 실행 시간: ~650ms
- 예상 병렬 실행 시간: ~250ms
- 개선율: **62% 감소**

**권장 수정**:
```typescript
const [a, b, c] = await Promise.all([
  fetchA(id),
  fetchB(id),
  fetchC(id),
])
```

#### 2. ...

### 요약

| 파일 | 패턴 수 | 예상 개선율 |
| ---- | ------- | ----------- |
| ... | ... | ... |

### 총 발견: N개 패턴
```

## Related Commands

- `/perf-audit` - Full performance analysis
- `/code-review` - Comprehensive code review
