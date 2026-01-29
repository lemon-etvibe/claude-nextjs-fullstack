---
description: Promise.all 최적화 검사 - 순차 await 패턴 찾아 병렬화 제안
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /waterfall-check 명령어

코드에서 순차적 await 패턴(waterfall)을 찾아 Promise.all() 병렬화를 제안합니다.

## 사용법

```
/waterfall-check                    # 전체 프로젝트 검사
/waterfall-check <파일경로>         # 특정 파일 검사
/waterfall-check src/app/(admin)    # 특정 디렉토리 검사
```

## Waterfall 문제란?

순차적으로 실행되는 독립적인 비동기 작업은 총 실행 시간을 불필요하게 증가시킵니다.

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

## 검사 기준

### 1. 연속된 await 문 (3개 이상)

```typescript
// DETECTED: 3개 이상 연속 await
const a = await fetchA()
const b = await fetchB()
const c = await fetchC()
```

### 2. 독립적인 요청인지 분석

```typescript
// 독립적 (병렬화 가능)
const user = await fetchUser(id)
const posts = await fetchPosts(id)

// 의존적 (순차 필요)
const user = await fetchUser(id)
const profile = await fetchProfile(user.profileId) // user 필요
```

### 3. Server Component 데이터 페칭

```typescript
// Page 또는 Server Component의 async 함수
async function CustomerPage({ params }) {
  const { id } = await params

  // 검사 대상
  const customer = await prisma.customer.findUnique(...)
  const campaigns = await prisma.campaign.findMany(...)
}
```

## 최적화 패턴

### 1. Promise.all (모두 성공 필요)

```typescript
const [customer, campaigns, stats] = await Promise.all([
  fetchCustomer(id),
  fetchCampaigns(id),
  fetchStats(id),
])
```

### 2. Promise.allSettled (일부 실패 허용)

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

### 3. 부분 병렬화 (의존성 있는 경우)

```typescript
// 먼저 병렬 실행
const [customer, campaigns] = await Promise.all([
  fetchCustomer(id),
  fetchCampaigns(id),
])

// 의존적인 요청은 이후 실행
const orders = await fetchOrders(customer.customerId)
```

### 4. Suspense 경계 활용 (RSC)

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

## 출력 형식

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

## 연계 명령어

- `/perf-audit` - 전체 성능 분석
- `/code-review` - 종합 코드 리뷰
