---
description: Drizzle schema design and review - data model, relationships, and index optimization
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
---

# /schema-design Command

Designs a Drizzle schema or reviews an existing schema.

## Usage

```
/schema-design "<requirements>"
/schema-design "캠페인과 인플루언서 N:M 관계 설계"
/schema-design review           # 기존 스키마 리뷰
```

## Schema Design Principles

### 1. Base Model Structure

```typescript
import { pgTable, text, timestamp, index } from 'drizzle-orm/pg-core'
import { createId } from '@paralleldrive/cuid2'

export const modelName = pgTable('model_name', {
  // 1. ID (CUID 권장)
  id: text('id').primaryKey().$defaultFn(() => createId()),

  // 2. 핵심 필드
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  status: text('status').notNull().default('ACTIVE'),

  // 3. 감사 필드
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdateFn(() => new Date()),
  // ⚠️ Prisma @updatedAt과 달리 $onUpdateFn()은 ORM update() 호출 시만 동작
}, (table) => [
  // 4. 인덱스
  index('model_name_status_created_idx').on(table.status, table.createdAt),
])
```

### 2. Relationship Patterns

#### 1:N Relationship

```typescript
import { relations } from 'drizzle-orm'

export const customers = pgTable('customers', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  // ...
})

export const campaigns = pgTable('campaigns', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  customerId: text('customer_id').notNull(),
  // ...
}, (table) => [
  index('campaigns_customer_id_idx').on(table.customerId),
])

export const customersRelations = relations(customers, ({ many }) => ({
  campaigns: many(campaigns),
}))

export const campaignsRelations = relations(campaigns, ({ one }) => ({
  customer: one(customers, {
    fields: [campaigns.customerId],
    references: [customers.id],
  }),
}))
```

#### N:M Relationship (explicit join table)

```typescript
export const campaignInfluencers = pgTable('campaign_influencers', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  campaignId: text('campaign_id').notNull().references(() => campaigns.id),
  influencerId: text('influencer_id').notNull().references(() => influencers.id),

  // 중간 테이블 고유 필드
  status: text('status').notNull().default('PENDING'),
  joinedAt: timestamp('joined_at').defaultNow().notNull(),
}, (table) => [
  uniqueIndex('ci_unique_idx').on(table.campaignId, table.influencerId),
])
```

### 3. Enum-like Pattern

```typescript
// ✅ 권장: text + TypeScript 타입 (마이그레이션 변경이 자유로움)
export type CustomerStatus = 'ACTIVE' | 'INACTIVE' | 'SUSPENDED'
export type CampaignStatus = 'DRAFT' | 'ACTIVE' | 'COMPLETED' | 'CANCELLED'

export const customers = pgTable('customers', {
  status: text('status').$type<CustomerStatus>().notNull().default('ACTIVE'),
})

// 🔶 선택적: pgEnum (DB 레벨 제약이 필요한 경우)
// 주의: 값 추가/삭제 시 ALTER TYPE 마이그레이션 필요
import { pgEnum } from 'drizzle-orm/pg-core'
export const customerStatusEnum = pgEnum('customer_status', ['ACTIVE', 'INACTIVE', 'SUSPENDED'])
```

### 4. Index Strategy

```typescript
export const campaigns = pgTable('campaigns', {
  // ...
}, (table) => [
  // 단일 필드 인덱스 - 자주 필터링하는 필드
  index('campaigns_status_idx').on(table.status),

  // 복합 인덱스 - 자주 함께 사용하는 필드
  index('campaigns_customer_status_idx').on(table.customerId, table.status),

  // 유니크 인덱스
  uniqueIndex('campaigns_slug_idx').on(table.slug),
])
```

### 5. Soft Delete Pattern

```typescript
export const customers = pgTable('customers', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  deletedAt: timestamp('deleted_at'), // null이면 활성, 값이 있으면 삭제됨
}, (table) => [
  index('customers_deleted_at_idx').on(table.deletedAt),
])

// 조회 시
import { isNull } from 'drizzle-orm'
const activeCustomers = await db.query.customers.findMany({
  where: isNull(customers.deletedAt),
})
```

## Schema Review Checklist

### Basic Quality

- [ ] All tables have id, createdAt, updatedAt
- [ ] Appropriate unique constraints
- [ ] Indexes on foreign key columns

### Relationship Design

- [ ] 1:N relationship has `relations()` defined
- [ ] N:M uses explicit join table
- [ ] Cascade behavior defined where needed

### Performance Optimization

- [ ] Indexes based on search patterns
- [ ] Composite index column order optimized
- [ ] Unnecessary indexes removed

### Consistency

- [ ] Table names in snake_case
- [ ] Column names in snake_case (via string parameter)
- [ ] TypeScript variable names in camelCase
- [ ] Type exports with `$inferSelect` / `$inferInsert`

## Output Format

### For New Design

```markdown
## 스키마 설계: {기능명}

### 요구사항 분석
- ...

### 데이터 모델

```typescript
// 제안하는 Drizzle 스키마
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
1. `npx drizzle-kit generate` - Generate migration
2. `npx drizzle-kit push` - Apply to local DB (dev)
3. `npx drizzle-kit migrate` - Apply migration (production)
