---
name: prisma-7
description: Prisma 7 Breaking Changes 및 마이그레이션 가이드
---

# Prisma 7 가이드

## Breaking Changes (v6 → v7)

### 1. 설정 파일 변경

```
프로젝트 루트/
├── prisma.config.ts    # 🆕 Prisma CLI 설정 (루트 필수!)
├── prisma/
│   └── schema.prisma   # 스키마 정의
├── .env                # Prisma CLI용 (dotenv/config)
└── .env.local          # Next.js용 (자동 로드)
```

#### prisma.config.ts (필수)

```typescript
import "dotenv/config"
import { defineConfig } from "prisma/config"

export default defineConfig({
  earlyAccess: true,
  schema: "prisma/schema.prisma",
})
```

### 2. pg Adapter 필수

```typescript
// src/lib/prisma.ts
import { Pool } from "pg"
import { PrismaPg } from "@prisma/adapter-pg"
import { PrismaClient } from "@/generated/prisma"

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

const adapter = new PrismaPg(pool)

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    adapter,
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  })

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma
```

### 3. 패키지 설치

```bash
pnpm add @prisma/client @prisma/adapter-pg pg
pnpm add -D prisma
```

### 4. Generator 설정

```prisma
// prisma/schema.prisma
generator client {
  provider        = "prisma-client-js"
  output          = "../src/generated/prisma"
  previewFeatures = ["driverAdapters"]
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

---

## 스키마 설계 패턴

### Enum 정의

```prisma
enum CustomerStatus {
  ACTIVE
  INACTIVE
  WITHDRAWN
}

enum CampaignStatus {
  RECRUITING
  MATCHED
  IN_PROGRESS
  POSTED
  COMPLETED
}
```

### 1:N 관계

```prisma
model Customer {
  id        String         @id @default(cuid())
  name      String
  email     String         @unique
  status    CustomerStatus @default(ACTIVE)

  // 1:N 관계 (Customer → Campaign)
  campaigns Campaign[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("customers")
}

model Campaign {
  id         String         @id @default(cuid())
  name       String
  status     CampaignStatus @default(RECRUITING)

  // 외래키
  customerId String
  customer   Customer @relation(fields: [customerId], references: [id], onDelete: Cascade)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([customerId])
  @@map("campaigns")
}
```

### N:M 관계 (중간 테이블)

```prisma
model CampaignInfluencer {
  id           String                    @id @default(cuid())
  campaignId   String

  // 스냅샷 데이터 (인플루언서 정보 복사)
  nickname     String
  followerCount Int

  status       CampaignInfluencerStatus @default(RECRUITING)

  // 관계
  campaign Campaign @relation(fields: [campaignId], references: [id], onDelete: Cascade)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([campaignId])
  @@map("campaign_influencers")
}
```

---

## 쿼리 패턴

### Select로 필요한 필드만

```typescript
// ✅ GOOD: 필요한 필드만 선택
const customers = await prisma.customer.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    _count: {
      select: { campaigns: true },
    },
  },
})

// ❌ BAD: 전체 필드 조회
const customers = await prisma.customer.findMany()
```

### Include로 관계 로드

```typescript
const customer = await prisma.customer.findUnique({
  where: { id },
  include: {
    campaigns: {
      select: {
        id: true,
        name: true,
        status: true,
      },
      orderBy: { createdAt: "desc" },
      take: 5,
    },
  },
})
```

### 집계 쿼리

```typescript
const stats = await prisma.customer.findUnique({
  where: { id },
  select: {
    id: true,
    name: true,
    _count: {
      select: {
        campaigns: true,
        inquiries: { where: { status: "PENDING" } },
      },
    },
  },
})
// 결과: { id, name, _count: { campaigns: 5, inquiries: 2 } }
```

### 트랜잭션

```typescript
const result = await prisma.$transaction(async (tx) => {
  // 1. 캠페인 생성
  const campaign = await tx.campaign.create({
    data: {
      name: "새 캠페인",
      customerId,
    },
  })

  // 2. 인플루언서 연결
  await tx.campaignInfluencer.createMany({
    data: influencerIds.map((id) => ({
      campaignId: campaign.id,
      influencerId: id,
    })),
  })

  return campaign
})
```

### 페이지네이션

```typescript
// 커서 기반 (대용량 추천)
const customers = await prisma.customer.findMany({
  take: 20,
  skip: 1,
  cursor: { id: lastId },
  orderBy: { createdAt: "desc" },
})

// 오프셋 기반
const [customers, total] = await Promise.all([
  prisma.customer.findMany({
    skip: (page - 1) * limit,
    take: limit,
    orderBy: { createdAt: "desc" },
  }),
  prisma.customer.count(),
])
```

---

## 마이그레이션 명령어

```bash
# 스키마 변경 후 DB 동기화 (개발용)
pnpm prisma db push

# 마이그레이션 생성 (프로덕션용)
pnpm prisma migrate dev --name add_campaigns

# 프로덕션 마이그레이션 적용
pnpm prisma migrate deploy

# Prisma Client 재생성
pnpm prisma generate

# DB 브라우저
pnpm prisma studio
```

---

## N+1 쿼리 방지

```typescript
// ❌ BAD: N+1 문제 발생
const customers = await prisma.customer.findMany()
for (const customer of customers) {
  const campaigns = await prisma.campaign.findMany({
    where: { customerId: customer.id },
  })
}

// ✅ GOOD: include 사용
const customers = await prisma.customer.findMany({
  include: {
    campaigns: true,
  },
})

// ✅ BETTER: 필요한 필드만
const customers = await prisma.customer.findMany({
  select: {
    id: true,
    name: true,
    campaigns: {
      select: { id: true, name: true },
    },
  },
})
```

---

## 환경 변수 설정

```env
# .env (Prisma CLI용)
DATABASE_URL="postgresql://user:pass@host:5432/db?pgbouncer=true"
DIRECT_URL="postgresql://user:pass@host:5432/db"

# .env.local (Next.js용)
DATABASE_URL="postgresql://user:pass@host:5432/db?pgbouncer=true"
```

### Supabase 사용 시

```env
# Pooler (앱용 - pgbouncer)
DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true"

# Direct (마이그레이션용)
DIRECT_URL="postgresql://postgres.[ref]:[password]@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
```

---

## 주의사항

1. **prisma.config.ts는 프로젝트 루트에 위치해야 함**
2. **pg adapter 사용 시 connection pool 설정 필수**
3. **`@map()` 디렉티브로 테이블명 snake_case 유지**
4. **인덱스는 자주 검색하는 필드에 `@@index()` 추가**
5. **`onDelete: Cascade` 주의 - 연쇄 삭제 발생**
