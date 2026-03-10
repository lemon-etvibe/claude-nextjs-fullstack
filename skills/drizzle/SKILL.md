---
name: drizzle
description: Drizzle ORM Guide - Schema Design, Query Patterns, Relations, and Migration
tested-with:
  enf: "1.1.0"
  drizzle-orm: "0.45.x"
  typescript: "5.x"
triggers:
  - drizzle
  - 스키마
  - 마이그레이션
  - 데이터베이스
  - ORM
  - schema
  - migration
  - database
  - pgTable
  - db
---

# Drizzle ORM Guide

## Setup

### 1. Installation

```bash
pnpm add drizzle-orm postgres @paralleldrive/cuid2
pnpm add -D drizzle-kit
```

### 2. DB Connection (`src/db/index.ts`)

```typescript
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const globalForDb = globalThis as unknown as { db: ReturnType<typeof drizzle> }

export const db =
  globalForDb.db ||
  drizzle(postgres(process.env.DATABASE_URL!), { schema })

if (process.env.NODE_ENV !== 'production') globalForDb.db = db
```

### 3. Configuration (`drizzle.config.ts`)

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './src/db/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

### 4. Local Development DB

```bash
# 방법 A: Supabase CLI (권장)
npx supabase start
# DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres

# 방법 B: Docker
docker run -d --name enf-db -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15
# DATABASE_URL=postgresql://postgres:postgres@localhost:5432/postgres
```

---

## Schema Design Patterns

### Base Model Structure

```typescript
import { pgTable, text, timestamp, index } from 'drizzle-orm/pg-core'
import { createId } from '@paralleldrive/cuid2'

export const customers = pgTable('customers', {
  // 1. ID (CUID 권장)
  id: text('id').primaryKey().$defaultFn(() => createId()),

  // 2. 핵심 필드
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  status: text('status').notNull().default('ACTIVE'),

  // 3. 감사 필드
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdateFn(() => new Date()),
  // ⚠️ Prisma @updatedAt과 달리 Drizzle은 자동 갱신이 없음
  // $onUpdateFn()은 ORM update() 호출 시만 동작, raw SQL에는 적용 안 됨
}, (table) => [
  // 4. 인덱스
  index('customers_status_idx').on(table.status),
])

// 타입 추론
export type Customer = typeof customers.$inferSelect
export type NewCustomer = typeof customers.$inferInsert
```

### 1:N Relationship

```typescript
import { relations } from 'drizzle-orm'

export const customers = pgTable('customers', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  name: text('name').notNull(),
})

export const campaigns = pgTable('campaigns', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  name: text('name').notNull(),
  status: text('status').notNull().default('RECRUITING'),
  customerId: text('customer_id').notNull().references(() => customers.id), // FK 제약조건
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdateFn(() => new Date()),
}, (table) => [
  index('campaigns_customer_id_idx').on(table.customerId),
])

// Relations 정의 (쿼리 API용 — relations()는 SQL FK가 아님, 쿼리 빌더 전용)
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

### N:M Relationship (Join Table)

```typescript
export const campaignInfluencers = pgTable('campaign_influencers', {
  id: text('id').primaryKey().$defaultFn(() => createId()),
  campaignId: text('campaign_id').notNull().references(() => campaigns.id),
  influencerId: text('influencer_id').notNull().references(() => influencers.id),

  // 중간 테이블 고유 필드
  nickname: text('nickname').notNull(),
  followerCount: integer('follower_count').notNull(),
  status: text('status').notNull().default('RECRUITING'),

  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull().$onUpdateFn(() => new Date()),
}, (table) => [
  index('ci_campaign_id_idx').on(table.campaignId),
  uniqueIndex('ci_unique_idx').on(table.campaignId, table.influencerId),
])
```

---

## Query Patterns

### Select (필요한 필드만)

```typescript
// ✅ GOOD: 필요한 필드만 선택
const result = await db.query.customers.findMany({
  columns: { id: true, name: true, email: true },
})

// ❌ BAD: 전체 필드 조회
const result = await db.select().from(customers)
```

### Select with Relations

```typescript
const customer = await db.query.customers.findFirst({
  where: eq(customers.id, id),
  with: {
    campaigns: {
      columns: { id: true, name: true, status: true },
      orderBy: (campaigns, { desc }) => [desc(campaigns.createdAt)],
      limit: 5,
    },
  },
})
```

### Insert

```typescript
const [newCustomer] = await db
  .insert(customers)
  .values({
    name: '홍길동',
    email: 'hong@test.com',
  })
  .returning()
```

### Update

```typescript
import { eq } from 'drizzle-orm'

const [updated] = await db
  .update(customers)
  .set({ name: '김철수', updatedAt: new Date() })
  .where(eq(customers.id, id))
  .returning()
```

### Delete

```typescript
await db
  .delete(customers)
  .where(eq(customers.id, id))
```

### Aggregation

```typescript
import { count, eq } from 'drizzle-orm'

const stats = await db
  .select({
    customerId: campaigns.customerId,
    campaignCount: count(campaigns.id),
  })
  .from(campaigns)
  .groupBy(campaigns.customerId)
```

### Transactions

```typescript
const result = await db.transaction(async (tx) => {
  // 1. 캠페인 생성
  const [campaign] = await tx
    .insert(campaigns)
    .values({ name: '새 캠페인', customerId })
    .returning()

  // 2. 인플루언서 연결 (스냅샷 데이터 포함)
  await tx.insert(campaignInfluencers).values(
    influencers.map((inf) => ({
      campaignId: campaign.id,
      nickname: inf.nickname,
      followerCount: inf.followerCount,
    }))
  )

  return campaign
})
```

### Pagination

```typescript
import { desc, gt } from 'drizzle-orm'

// 커서 기반 (대용량 추천)
const results = await db.query.customers.findMany({
  where: gt(customers.createdAt, cursor),
  orderBy: [desc(customers.createdAt)],
  limit: 20,
})

// 오프셋 기반
const [results, totalCount] = await Promise.all([
  db.query.customers.findMany({
    orderBy: [desc(customers.createdAt)],
    offset: (page - 1) * limit,
    limit,
  }),
  db.select({ count: count() }).from(customers),
])
```

---

## Preventing N+1 Queries

```typescript
// ❌ BAD: N+1 문제 발생
const allCustomers = await db.select().from(customers)
for (const customer of allCustomers) {
  const customerCampaigns = await db
    .select()
    .from(campaigns)
    .where(eq(campaigns.customerId, customer.id))
}

// ✅ GOOD: relations 사용
const allCustomers = await db.query.customers.findMany({
  with: { campaigns: true },
})

// ✅ BETTER: 필요한 필드만
const allCustomers = await db.query.customers.findMany({
  columns: { id: true, name: true },
  with: {
    campaigns: {
      columns: { id: true, name: true },
    },
  },
})
```

---

## Migration Commands

```bash
# 마이그레이션 생성
npx drizzle-kit generate

# 로컬 DB에 즉시 반영 (개발용)
npx drizzle-kit push

# 마이그레이션 파일로 반영 (프로덕션용)
npx drizzle-kit migrate

# 스키마 브라우저 (Studio)
npx drizzle-kit studio
```

---

## Environment Variable Setup

```env
# .env.local (로컬 개발)
DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"

# .env.production (프로덕션 - Supabase)
DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true"
```

---

## Important Notes

1. **`pgTable`로 스키마 정의** -- Drizzle은 TypeScript 코드로 스키마를 작성
2. **`relations()`는 쿼리 API 전용** -- SQL 외래키 제약조건은 `.references()` 로 별도 설정 필요
3. **`$defaultFn()`으로 CUID 생성** -- 클라이언트 사이드 ID 생성
4. **`@@map` 대신 컬럼명 직접 지정** -- `text('snake_case')` 형태
5. **인덱스는 테이블 정의 콜백에서 설정** -- `(table) => [index(...)]`
6. **`updatedAt` 자동 갱신 없음** -- `.$onUpdateFn(() => new Date())` 또는 update 시 `.set({ updatedAt: new Date() })` 명시 필요
7. **Enum은 `text` + TypeScript 타입 권장** -- `pgEnum`은 마이그레이션 시 ALTER TYPE 필요하므로 선택적 사용

### Enum 처리 가이드라인

```typescript
// ✅ 권장: text + TypeScript 타입 (마이그레이션 변경이 자유로움)
export type CampaignStatus = 'DRAFT' | 'ACTIVE' | 'COMPLETED' | 'CANCELLED'

export const campaigns = pgTable('campaigns', {
  status: text('status').$type<CampaignStatus>().notNull().default('DRAFT'),
})

// 🔶 선택적: pgEnum (DB 레벨 제약이 필요한 경우)
// 주의: 값 추가/삭제 시 ALTER TYPE 마이그레이션 필요
import { pgEnum } from 'drizzle-orm/pg-core'
export const campaignStatusEnum = pgEnum('campaign_status', ['DRAFT', 'ACTIVE', 'COMPLETED', 'CANCELLED'])
```
