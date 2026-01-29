---
description: 프로젝트 구조 및 개발 가이드 안내
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /init 명령어

etvibe-nextjs-fullstack 프로젝트의 구조와 개발 가이드를 안내합니다.

## 사용법

```
/init                   # 전체 프로젝트 가이드
/init <영역>            # 특정 영역 가이드
/init admin             # 관리자 영역
/init site              # 고객 영역
/init auth              # 인증 시스템
/init prisma            # 데이터베이스
```

## 기술 스택

| 카테고리 | 기술 | 버전 |
| -------- | ---- | ---- |
| Framework | Next.js | 16.x |
| Runtime | React | 19.x |
| ORM | Prisma | 7.x |
| Auth | Better Auth | 1.4.x |
| Styling | Tailwind CSS | 4.x |
| UI | shadcn/ui | latest |
| Language | TypeScript | 5.x |

## 프로젝트 구조

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

## 핵심 패턴

### 1. Co-location 원칙

```
src/app/(admin)/
├── _actions/         # _ prefix = 라우팅 제외
├── _components/
├── _lib/
└── admin/            # 실제 라우트
```

### 2. Server Action 패턴

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

### 3. 컴포넌트 구분

| 위치 | 용도 |
| ---- | ---- |
| `_components/` | Route Group 전용 |
| `components/ui/` | 전역 공유 (shadcn) |

## 개발 워크플로우

```
/enf:task "기능 설명"        # 1. 브랜치 생성
/enf:design-feature "..."    # 2. (선택) 아키텍처 설계
# 구현 작업                  # 3. 코드 작성
/enf:code-review <file>      # 4. 코드 리뷰
/enf:commit                  # 5. 커밋
/enf:push                    # 6. 푸시
/enf:pr                      # 7. PR 생성
```

> **참고**: 모든 Commands는 `/enf:` 네임스페이스 사용

## 사용 가능한 Commands

### 핵심

| 명령어 | 설명 |
| ------ | ---- |
| `/enf:code-review` | 코드 품질 검사 |
| `/enf:design-feature` | 기능 아키텍처 설계 |
| `/enf:schema-design` | Prisma 스키마 설계 |
| `/enf:perf-audit` | 성능 분석 |

### 개발 워크플로우

| 명령어 | 설명 |
| ------ | ---- |
| `/enf:refactor` | 코드 최적화 제안 |
| `/enf:type-check` | TypeScript 검증 |
| `/enf:waterfall-check` | Promise.all 최적화 검사 |

### Git 워크플로우

| 명령어 | 설명 |
| ------ | ---- |
| `/enf:task` | 업무 정의 → 브랜치 생성 |
| `/enf:commit` | 커밋 생성 |
| `/enf:push` | 원격 푸시 |
| `/enf:pr` | PR 생성 |

### 문서화

| 명령어 | 설명 |
| ------ | ---- |
| `/enf:generate-docs` | API/Action 문서 생성 |
| `/enf:component-docs` | 컴포넌트 Props 문서 |
| `/enf:update-changelog` | CHANGELOG 업데이트 |

## 에이전트

| 에이전트 | 역할 |
| -------- | ---- |
| `dev-assistant` | 코드 리뷰, 리팩토링, 구현 |
| `architecture-expert` | 시스템 설계, 데이터 모델링 |
| `performance-expert` | 성능 최적화, 번들 분석 |
| `docs-writer` | 기술 문서 작성 |

## 시작하기

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

## 추가 정보

자세한 내용은 README.md를 참조하세요.
