---
description: Project structure and development guide overview
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /init Command

Provides an overview of the etvibe-nextjs-fullstack project structure and development guide.

## Usage

```
/init                   # 전체 프로젝트 가이드
/init <area>            # 특정 영역 가이드
/init admin             # 관리자 영역
/init site              # 고객 영역
/init auth              # 인증 시스템
/init prisma            # 데이터베이스
```

## Tech Stack

| Category | Technology | Version |
| -------- | ---- | ---- |
| Framework | Next.js | 16.x |
| Runtime | React | 19.x |
| ORM | Prisma | 7.x |
| Auth | Better Auth | 1.4.x |
| Styling | Tailwind CSS | 4.x |
| UI | shadcn/ui | latest |
| Language | TypeScript | 5.x |

## Project Structure

```
src/
├── app/
│   ├── (admin)/              # 관리자 영역
│   │   ├── _actions/         # Admin Server Actions
│   │   ├── _components/      # Admin 전용 컴포넌트
│   │   ├── _lib/             # Admin 전용 훅/스키마
│   │   └── admin/            # 라우트
│   │       ├── (auth)/       # 인증 불필요 (login)
│   │       └── (protected)/  # 인증 필요
│   │
│   ├── (site)/               # 고객 영역
│   │   ├── _actions/         # Site Server Actions
│   │   ├── _components/      # Site 전용 컴포넌트
│   │   ├── _lib/             # Site 전용 훅/스키마
│   │   ├── (main)/           # Header+Footer 레이아웃
│   │   ├── (auth)/           # 고객 인증
│   │   └── (customer)/       # 마이페이지
│   │
│   └── api/                  # API Routes
│       ├── auth/[...all]/    # Better Auth
│       └── files/            # 파일 업로드
│
├── components/
│   └── ui/                   # shadcn/ui 컴포넌트
│
├── lib/
│   ├── prisma.ts             # Prisma 클라이언트
│   └── auth.ts               # Better Auth 설정
│
└── generated/
    └── prisma/               # Prisma Client (생성됨)
```

## Core Patterns

### 1. Co-location Principle

```
src/app/(admin)/
├── _actions/         # _ prefix = 라우팅 제외
├── _components/
├── _lib/
└── admin/            # 실제 라우트
```

### 2. Server Action Pattern

```typescript
"use server"

import { auth } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { headers } from "next/headers"
import { revalidatePath } from "next/cache"

export async function updateCustomer(
  id: string,
  prevState: unknown,
  formData: FormData
) {
  // 1. 인증 검사
  const session = await auth.api.getSession({ headers: await headers() })
  if (!session) return { error: "인증이 필요합니다." }

  // 2. Zod 검증
  // 3. DB 작업
  // 4. 캐시 무효화
  revalidatePath("/admin/customers")

  return { success: true }
}
```

### 3. Component Classification

| Location | Purpose |
| ---- | ---- |
| `_components/` | Route Group specific |
| `components/ui/` | Global shared (shadcn) |

## Development Workflow

```
/enf:task "기능 설명"        # 1. 브랜치 생성
/enf:design-feature "..."    # 2. (선택) 아키텍처 설계
# 구현 작업                  # 3. 코드 작성
/enf:code-review <file>      # 4. 코드 리뷰
/enf:commit                  # 5. 커밋
/enf:push                    # 6. 푸시
/enf:pr                      # 7. PR 생성
```

> **Note**: All Commands use the `/enf:` namespace

## Available Commands

### Core

| Command | Description |
| ------ | ---- |
| `/enf:code-review` | Code quality review |
| `/enf:design-feature` | Feature architecture design |
| `/enf:schema-design` | Prisma schema design |
| `/enf:perf-audit` | Performance analysis |

### Development Workflow

| Command | Description |
| ------ | ---- |
| `/enf:refactor` | Code optimization suggestions |
| `/enf:type-check` | TypeScript verification |
| `/enf:waterfall-check` | Promise.all optimization check |

### Testing

| Command | Description |
| ------ | ---- |
| `/enf:test` | Run and generate tests |

### Git Workflow

| Command | Description |
| ------ | ---- |
| `/enf:task` | Define task and create branch |
| `/enf:commit` | Create commit |
| `/enf:push` | Push to remote |
| `/enf:pr` | Create PR |

### Documentation

| Command | Description |
| ------ | ---- |
| `/enf:generate-docs` | Generate API/Action documentation |
| `/enf:component-docs` | Component Props documentation |
| `/enf:update-changelog` | Update CHANGELOG |

## Agents

| Agent | Role |
| -------- | ---- |
| `dev-assistant` | Code review, refactoring, implementation |
| `architecture-expert` | System design, data modeling |
| `performance-expert` | Performance optimization, bundle analysis |
| `docs-writer` | Technical documentation |

## Getting Started

```bash
# 의존성 설치
pnpm install

# 환경변수 설정
cp .env.example .env.local

# DB 마이그레이션
pnpm prisma migrate dev

# 개발 서버 실행
pnpm dev
```

## Additional Information

See README.md for more details.
