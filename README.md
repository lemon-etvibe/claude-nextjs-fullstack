# etvibe-nextjs-fullstack

Next.js 16 + Prisma 7 + Better Auth 풀스택 개발을 위한 Claude Code 플러그인 패키지

## 기술 스택

- **Framework**: Next.js 16.x App Router + Turbopack
- **Runtime**: React 19.x
- **ORM**: Prisma 7.x (pg adapter)
- **Auth**: Better Auth 1.4.x
- **Styling**: Tailwind CSS 4.x + shadcn/ui

---

## 설치

### 1. 플러그인 클론

```bash
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git
cd etvibe-nextjs-fullstack
```

### 2. 외부 의존성 설치

```bash
chmod +x scripts/install-dependencies.sh
./scripts/install-dependencies.sh
```

또는 수동으로 설치:

```bash
# MCP 서버
claude mcp add prisma-local npx prisma mcp

# 마켓플레이스
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents

# Anthropic 공식 플러그인
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory

# Vercel Labs 스킬
npx skills add vercel-labs/next-skills
claude plugin install react-best-practices@agent-skills

# wshobson 플러그인
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
```

### 3. 옵셔널 플러그인 (선택)

```bash
# 고품질 UI 디자인
claude plugin install frontend-design@claude-plugin-directory

# 접근성/UX 감사
claude plugin install web-design-guidelines@agent-skills
```

---

## 패키지 구성

### 커스텀 에이전트 (4개)

| 에이전트 | 설명 | 주요 도구 |
|---------|------|----------|
| `dev-assistant` | Next.js 16 + TypeScript 개발 지원 | Read, Edit, context7 MCP |
| `architecture-expert` | 시스템 설계, 데이터 모델링 | Read, Grep, next-devtools MCP |
| `performance-expert` | Core Web Vitals 최적화 | next-devtools MCP, browser_eval |
| `docs-writer` | 기술 문서 작성 | Read, Write, context7 MCP |

### 커스텀 스킬 (4개)

| 스킬 | 설명 |
|------|------|
| `coding-conventions` | 네이밍, import 순서, 커밋 규칙 |
| `tailwind-v4-shadcn` | Tailwind v4 + shadcn/ui 폼 패턴 |
| `better-auth` | Better Auth 인증 패턴 |
| `prisma-7` | Prisma 7 Breaking Changes |

### 외부 플러그인 (필수)

| 플러그인 | 출처 | 용도 |
|---------|------|------|
| `Playwright` | Anthropic 공식 | E2E 테스트 실행 |
| `pr-review-toolkit` | Anthropic 공식 | PR 리뷰 자동화 (6가지 관점) |
| `commit-commands` | Anthropic 공식 | Git 워크플로우 자동화 |
| `feature-dev` | Anthropic 공식 | 기능 개발 워크플로우 |
| `security-guidance` | Anthropic 공식 | 보안 취약점 경고 |
| `react-best-practices` | Vercel Labs | React/Next.js 성능 최적화 (40+ 규칙) |
| `next-best-practices` | Vercel Labs | Next.js 핵심 지식 (자동 적용) |
| `javascript-typescript` | wshobson/agents | JS/TS 전문가 에이전트 |
| `database-design` | wshobson/agents | 스키마 설계 보완 |

### 외부 플러그인 (옵셔널)

| 플러그인 | 출처 | 용도 |
|---------|------|------|
| `frontend-design` | Anthropic 공식 | 고품질 프론트엔드 UI |
| `web-design-guidelines` | Vercel Labs | 접근성/UX 감사 (100+ 규칙) |

### MCP 서버

| MCP | 용도 |
|-----|------|
| `context7` | 라이브러리 최신 문서 조회 |
| `next-devtools` | Next.js 16 개발 서버 연동 |
| `Prisma MCP` | 마이그레이션 실행, Prisma Studio |

---

## 주요 사용법

| 작업 | 명령어/방법 |
|-----|------------|
| PR 리뷰 | `/review-pr` 또는 "이 PR 리뷰해줘" |
| E2E 테스트 | "Playwright로 로그인 테스트 실행해줘" |
| 폼 생성 | "shadcn 폼 컴포넌트 생성해줘" |
| 인증 구현 | "Better Auth 로그인 구현해줘" |
| 마이그레이션 | "Prisma 마이그레이션 실행해줘" |
| 보안 검사 | "이 코드 보안 검사해줘" |
| 커밋 생성 | `/commit` |
| 기능 개발 | "로그인 기능 구현해줘" |
| Next.js 업그레이드 | `/next-upgrade` |
| UI 리뷰 | `/web-design-guidelines` (옵셔널 설치 시) |

---

## 프로젝트 구조 (권장)

```
src/app/
├── (admin)/              # 관리자 영역
│   ├── _actions/         # Admin 전용 Server Actions
│   ├── _components/      # Admin 전용 컴포넌트
│   ├── _lib/             # Admin 전용 훅/스키마
│   └── admin/            # 실제 라우트
│       ├── (auth)/       # 인증 불필요
│       └── (protected)/  # 인증 필요
│
├── (site)/               # 고객 영역
│   ├── _actions/         # Site 전용 Server Actions
│   ├── _components/      # Site 전용 컴포넌트
│   ├── _lib/             # Site 전용 훅/스키마
│   ├── (main)/           # Header+Footer 레이아웃
│   ├── (auth)/           # 고객 인증
│   └── (customer)/       # 마이페이지 (인증 필요)
│
└── api/                  # API Routes
    ├── auth/[...all]/    # Better Auth
    └── files/            # 파일 업로드/다운로드

src/components/ui/        # 공통 UI (shadcn/ui)
src/lib/                  # 공통 유틸 (prisma, auth)
src/generated/prisma/     # Prisma Client (생성됨)
```

> `_` prefix 폴더는 Next.js 라우팅에서 제외됨 (Private Folders)

---

## 신뢰 출처

| 출처 | Stars | 설명 |
|------|------:|------|
| [Anthropic 공식](https://github.com/anthropics/claude-plugins-official) | 5.2k | Playwright, pr-review-toolkit, commit-commands 등 |
| [Vercel Labs agent-skills](https://github.com/vercel-labs/agent-skills) | 17.5k | react-best-practices, web-design-guidelines |
| [Vercel Labs next-skills](https://github.com/vercel-labs/next-skills) | 290 | next-best-practices, /next-upgrade |
| [wshobson/agents](https://github.com/wshobson/agents) | 26.7k | javascript-typescript, database-design |
| [Prisma MCP](https://github.com/prisma/mcp) | 35 | Prisma 공식 MCP |

---

## 라이선스

MIT
