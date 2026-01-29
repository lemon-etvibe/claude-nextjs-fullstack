---
name: schema-design
description: Prisma 스키마 설계 및 리뷰 - 데이터 모델, 관계, 인덱스 최적화
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
---

# /schema-design 명령어

Prisma 스키마를 설계하거나 기존 스키마를 리뷰합니다.

## 사용법

```
/schema-design "<요구사항>"
/schema-design "캠페인과 인플루언서 N:M 관계 설계"
/schema-design review           # 기존 스키마 리뷰
```

## 스키마 설계 원칙

### 1. 기본 모델 구조

```prisma
model ModelName {
  // 1. ID (CUID 권장)
  id        String   @id @default(cuid())

  // 2. 핵심 필드
  name      String
  email     String   @unique
  status    Status   @default(ACTIVE)

  // 3. 감사 필드
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // 4. 관계
  posts     Post[]

  // 5. 인덱스
  @@index([status, createdAt])
}
```

### 2. 관계 패턴

#### 1:N 관계

```prisma
model Customer {
  id        String     @id @default(cuid())
  campaigns Campaign[]
}

model Campaign {
  id         String   @id @default(cuid())
  customerId String
  customer   Customer @relation(fields: [customerId], references: [id])

  @@index([customerId])
}
```

#### N:M 관계 (명시적 중간 테이블)

```prisma
model Campaign {
  id           String                @id @default(cuid())
  influencers  CampaignInfluencer[]
}

model Influencer {
  id        String                @id @default(cuid())
  campaigns CampaignInfluencer[]
}

model CampaignInfluencer {
  campaignId   String
  influencerId String
  campaign     Campaign   @relation(fields: [campaignId], references: [id])
  influencer   Influencer @relation(fields: [influencerId], references: [id])

  // 중간 테이블 고유 필드
  status       CampaignInfluencerStatus @default(PENDING)
  joinedAt     DateTime                 @default(now())

  @@id([campaignId, influencerId])
}
```

### 3. Enum 정의

```prisma
enum CustomerStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
}

enum CampaignStatus {
  DRAFT
  ACTIVE
  COMPLETED
  CANCELLED
}
```

### 4. 인덱스 전략

```prisma
model Campaign {
  // ...

  // 단일 필드 인덱스 - 자주 필터링하는 필드
  @@index([status])

  // 복합 인덱스 - 자주 함께 사용하는 필드
  @@index([customerId, status])

  // 정렬용 인덱스
  @@index([createdAt(sort: Desc)])
}
```

### 5. 소프트 삭제 패턴

```prisma
model Customer {
  id        String    @id @default(cuid())
  deletedAt DateTime?  // null이면 활성, 값이 있으면 삭제됨

  @@index([deletedAt])
}

// 조회 시
const customers = await prisma.customer.findMany({
  where: { deletedAt: null }
})
```

## 스키마 리뷰 체크리스트

### 기본 품질

- [ ] 모든 모델에 id, createdAt, updatedAt 존재
- [ ] 적절한 @unique 제약 조건
- [ ] 외래키에 @@index 적용

### 관계 설계

- [ ] 1:N 관계 올바른 방향
- [ ] N:M은 명시적 중간 테이블 사용
- [ ] onDelete 동작 명시 (필요 시)

### 성능 최적화

- [ ] 검색 패턴 기반 인덱스
- [ ] 복합 인덱스 순서 최적화
- [ ] 불필요한 인덱스 제거

### 일관성

- [ ] 필드명 camelCase
- [ ] 모델명 PascalCase
- [ ] Enum명 PascalCase, 값은 UPPER_SNAKE_CASE

## 출력 형식

### 신규 설계 시

```markdown
## 스키마 설계: {기능명}

### 요구사항 분석
- ...

### 데이터 모델

```prisma
// 제안하는 스키마
```

### 관계 다이어그램
```
Customer 1--* Campaign *--* Influencer
```

### 인덱스 전략
| 인덱스 | 목적 | 사용 쿼리 |
| ------ | ---- | --------- |

### 마이그레이션 순서
1. ...
```

### 리뷰 시

```markdown
## 스키마 리뷰 결과

### 발견된 이슈

#### 심각
- ...

#### 경고
- ...

### 개선 제안
- ...

### 잘된 점
- ...
```

## 연계 에이전트

이 명령어는 `architecture-expert` 에이전트의 데이터 모델링 가이드라인을 기반으로 합니다.

## 후속 작업

스키마 변경 후:
1. `pnpm prisma validate` - 스키마 검증
2. `pnpm prisma migrate dev --name <name>` - 마이그레이션
3. `pnpm prisma generate` - 클라이언트 재생성
