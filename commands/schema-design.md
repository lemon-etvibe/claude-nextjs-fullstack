---
description: Prisma schema design and review - data model, relationships, and index optimization
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
---

# /schema-design Command

Designs a Prisma schema or reviews an existing schema.

## Usage

```
/schema-design "<requirements>"
/schema-design "캠페인과 인플루언서 N:M 관계 설계"
/schema-design review           # 기존 스키마 리뷰
```

## Schema Design Principles

### 1. Base Model Structure

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

### 2. Relationship Patterns

#### 1:N Relationship

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

#### N:M Relationship (explicit join table)

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

### 3. Enum Definitions

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

### 4. Index Strategy

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

### 5. Soft Delete Pattern

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

## Schema Review Checklist

### Basic Quality

- [ ] All models have id, createdAt, updatedAt
- [ ] Appropriate @unique constraints
- [ ] @@index applied to foreign keys

### Relationship Design

- [ ] 1:N relationship direction is correct
- [ ] N:M uses explicit join table
- [ ] onDelete behavior specified (when needed)

### Performance Optimization

- [ ] Indexes based on search patterns
- [ ] Composite index order optimized
- [ ] Unnecessary indexes removed

### Consistency

- [ ] Field names in camelCase
- [ ] Model names in PascalCase
- [ ] Enum names in PascalCase, values in UPPER_SNAKE_CASE

## Output Format

### For New Design

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

### For Review

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

## Related Agents

This command is based on the `architecture-expert` agent's data modeling guidelines.

## Follow-up Tasks

After schema changes:
1. `pnpm prisma validate` - Validate schema
2. `pnpm prisma migrate dev --name <name>` - Run migration
3. `pnpm prisma generate` - Regenerate client
