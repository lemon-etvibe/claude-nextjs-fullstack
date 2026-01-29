# etvibe-nextjs-fullstack (enf)

Next.js 16 + Prisma 7 + Better Auth 풀스택 개발을 위한 Claude Code 플러그인

> **Plugin Name**: `enf` - 모든 Commands는 `/enf:command` 형식으로 사용 (예: `/enf:commit`, `/enf:code-review`)

## 기술 스택

| 기술 | 버전 | 용도 |
|------|------|------|
| Next.js | 16.x | App Router + Turbopack |
| React | 19.x | UI 프레임워크 |
| Prisma | 7.x | ORM (pg adapter) |
| Better Auth | 1.4.x | 인증 |
| Tailwind CSS | 4.x | 스타일링 |
| shadcn/ui | latest | UI 컴포넌트 |

---

## 설치

### Step 1: 플러그인 설치

```bash
# 마켓플레이스 추가 (팀 공유 시)
claude plugin marketplace add https://github.com/lemon-etvibe/etvibe-nextjs-fullstack

# 플러그인 설치
claude plugin install etvibe-nextjs-fullstack
```

또는 로컬에서 직접 테스트:

```bash
# 레포 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git

# 로컬 플러그인으로 실행
claude --plugin-dir ./etvibe-nextjs-fullstack
```

### Step 2: 외부 플러그인 설치

MCP 서버 (context7, next-devtools, prisma-local)는 플러그인 설치 시 **자동으로 설정**됩니다.

외부 플러그인은 스크립트로 설치합니다:

```bash
cd etvibe-nextjs-fullstack
chmod +x scripts/install-plugins.sh
./scripts/install-plugins.sh
```

### Step 3: 확인

```bash
# Claude Code 실행
claude

# 에이전트 목록 확인
/agents

# MCP 서버 확인
/mcp
```

---

## 패키지 구성

### 번들 포함 (자동 설정)

| 구성 요소 | 내용 |
|----------|------|
| **에이전트** | dev-assistant, architecture-expert, performance-expert, docs-writer |
| **스킬** | coding-conventions, better-auth, prisma-7, tailwind-v4-shadcn |
| **MCP 서버** | context7, next-devtools, prisma-local |

### 외부 플러그인 (스크립트 설치)

| 출처 | 플러그인 | 용도 |
|------|---------|------|
| Anthropic | playwright | E2E 테스트 |
| Anthropic | pr-review-toolkit | PR 리뷰 (`/review-pr`) |
| Anthropic | commit-commands | 커밋 생성 (`/commit`) |
| Anthropic | feature-dev | 기능 개발 |
| Anthropic | security-guidance | 보안 검사 |
| Vercel Labs | react-best-practices | React 최적화 (자동 적용) |
| wshobson | javascript-typescript | JS/TS 전문가 |
| wshobson | database-design | 스키마 설계 |

### 옵셔널 플러그인

| 출처 | 플러그인 | 용도 |
|------|---------|------|
| Anthropic | frontend-design | 고품질 UI 디자인 |
| Vercel Labs | web-design-guidelines | 접근성/UX 감사 |

---

## 슬래시 Commands (15개)

> **네임스페이스**: 모든 Commands는 `/enf:` 접두사 사용 (예: `/enf:commit`)

### 핵심 Commands

| Command | 설명 | 연계 에이전트 |
|---------|------|--------------|
| `/enf:code-review` | 코드 품질 검사 (TypeScript, 성능, 보안) | dev-assistant |
| `/enf:design-feature` | 새 기능 아키텍처 설계 | architecture-expert |
| `/enf:schema-design` | Prisma 스키마 설계/리뷰 | architecture-expert |
| `/enf:perf-audit` | 성능 분석 (번들, Core Web Vitals) | performance-expert |

### 개발 워크플로우 Commands

| Command | 설명 |
|---------|------|
| `/enf:refactor` | 코드 리팩토링 제안 |
| `/enf:type-check` | TypeScript 타입 검증 |
| `/enf:waterfall-check` | 순차 await 패턴 찾아 Promise.all 제안 |

### Git 워크플로우 Commands

| Command | 설명 |
|---------|------|
| `/enf:task` | 업무 정의 → Git 브랜치 생성 |
| `/enf:commit` | Conventional Commits 형식 커밋 생성 |
| `/enf:push` | 원격 저장소 푸시 (안전 체크 포함) |
| `/enf:pr` | GitHub PR 생성 (자동 템플릿) |

> **외부 플러그인과의 관계**:
> - `/commit` (commit-commands) - 외부 플러그인의 커밋 명령
> - `/enf:commit` - 이 플러그인의 커밋 명령 (폴백용)
> - 둘 다 사용 가능하며 충돌 없음

### 문서화 Commands

| Command | 설명 | 연계 에이전트 |
|---------|------|--------------|
| `/enf:generate-docs` | API/Server Action 문서 자동 생성 | docs-writer |
| `/enf:component-docs` | 컴포넌트 Props 문서 생성 | docs-writer |
| `/enf:update-changelog` | CHANGELOG.md 자동 업데이트 | docs-writer |

### 프로젝트 가이드

| Command | 설명 |
|---------|------|
| `/enf:init` | 프로젝트 구조 및 개발 가이드 안내 |

---

## 자동화 Hooks (3개)

파일 저장 시 자동으로 실행되는 검사 스크립트입니다.

| Hook | 트리거 | 동작 |
|------|--------|------|
| TypeScript 검사 | `.ts/.tsx` 파일 저장 | lint/type 체크 안내 메시지 |
| Server Action 검증 | `_actions/*.ts` 저장 | 인증 패턴 검사, `use server` 확인 |
| Prisma 스키마 검증 | `schema.prisma` 수정 | 마이그레이션 절차 안내 |

---

## 개발 워크플로우 예시

```bash
# 1. 작업 시작 (브랜치 생성)
/enf:task "고객 검색 기능 구현"

# 2. (선택) 복잡한 기능은 설계 먼저
/enf:design-feature "고객 검색 필터 및 정렬"

# 3. 코드 작성 후 리뷰
/enf:code-review src/app/(admin)/_actions/customer.ts

# 4. 성능 검사
/enf:waterfall-check src/app/(admin)/

# 5. 커밋 및 푸시 (외부 플러그인 또는 enf 사용)
/commit                    # commit-commands 플러그인
/enf:commit                # 또는 이 플러그인
/enf:push

# 6. PR 생성
/enf:pr
```

---

## 주요 기능

### Git 워크플로우

| 작업 | 명령어 | 설명 |
|------|--------|------|
| 작업 시작 | `/enf:task` | 브랜치 생성 및 컨텍스트 설정 |
| 커밋 생성 | `/enf:commit` 또는 `/commit` | 변경사항 분석 후 커밋 생성 |
| PR 리뷰 | `/review-pr` | 보안/타입/성능 등 6가지 관점 리뷰 (외부) |
| PR 생성 | `/enf:pr` | 브랜치 비교 후 PR 생성 |

### 개발 작업

| 작업 | 프롬프트 예시 | 담당 |
|------|-------------|------|
| 기능 개발 | "로그인 기능 구현해줘" | dev-assistant + feature-dev |
| 폼 생성 | "고객 등록 폼 만들어줘" | tailwind-v4-shadcn 스킬 |
| 인증 구현 | "Better Auth 세션 체크 추가해줘" | better-auth 스킬 |
| DB 작업 | "Customer 모델에 status 필드 추가해줘" | prisma-7 스킬 |
| 코드 리뷰 | `/enf:code-review <파일>` | dev-assistant |

### 설계 & 테스트

| 작업 | 프롬프트 예시 | 담당 |
|------|-------------|------|
| 기능 설계 | `/enf:design-feature "캠페인 관리"` | architecture-expert |
| 스키마 설계 | `/enf:schema-design "N:M 관계"` | architecture-expert |
| E2E 테스트 | "로그인 E2E 테스트 작성해줘" | playwright |
| 성능 분석 | `/enf:perf-audit src/app/` | performance-expert |

---

## 커스텀 에이전트

### dev-assistant
- **역할**: 일상적인 개발 작업 지원
- **기능**: 코드 리뷰, 리팩토링, TypeScript 타입 검증
- **MCP**: context7

### architecture-expert
- **역할**: 설계 전문가 (구현 X, 설계만)
- **기능**: 시스템 설계, 데이터 모델링, 라우팅 구조 결정
- **MCP**: context7, next-devtools

### performance-expert
- **역할**: 성능 최적화 전문가
- **기능**: Core Web Vitals 개선, 번들 분석
- **MCP**: next-devtools

### docs-writer
- **역할**: 기술 문서 작성
- **기능**: README, API 문서, 컴포넌트 문서
- **MCP**: context7

---

## 커스텀 스킬

### coding-conventions
- 네이밍 규칙 (PascalCase, camelCase, kebab-case)
- Import 순서 규칙
- Git 커밋 컨벤션
- TypeScript 규칙 (any 금지)

### tailwind-v4-shadcn
- Tailwind CSS v4 변경사항 (@theme)
- shadcn/ui 폼 패턴 (React Hook Form + Zod)
- Server Action 통합 패턴

### better-auth
- Better Auth 설정 패턴
- Server Component/Action에서 세션 확인
- 역할 기반 접근 제어 (RBAC)

### prisma-7
- Prisma 7 Breaking Changes (prisma.config.ts, pg adapter)
- 쿼리 최적화 패턴 (select, include, N+1 방지)
- 트랜잭션 패턴

---

## 프로젝트 구조 (권장)

```
src/app/
├── (admin)/              # 관리자 영역
│   ├── _actions/         # Admin 전용 Server Actions
│   ├── _components/      # Admin 전용 컴포넌트
│   ├── _lib/             # Admin 전용 훅/스키마/타입
│   └── admin/            # 실제 라우트
│       ├── (auth)/       # 인증 불필요 (login)
│       └── (protected)/  # 인증 필요 (dashboard, customers)
│
├── (site)/               # 고객 영역
│   ├── _actions/         # Site 전용 Server Actions
│   ├── _components/      # Site 전용 컴포넌트
│   ├── _lib/             # Site 전용 훅/스키마/타입
│   ├── (main)/           # Header+Footer 레이아웃
│   ├── (auth)/           # 고객 인증 (login, register)
│   └── (customer)/       # 마이페이지 (인증 필요)
│
└── api/                  # API Routes
    ├── auth/[...all]/    # Better Auth
    └── files/            # 파일 업로드/다운로드

src/components/ui/        # 공통 UI (shadcn/ui)
src/lib/                  # 공통 유틸 (prisma, auth)
src/generated/prisma/     # Prisma Client (생성됨)
```

**핵심 원칙:**
- `_` prefix 폴더는 Next.js 라우팅에서 제외 (Private Folders)
- 관련 코드는 한 곳에 모으기 (Co-location)
- `(group)` Route Group으로 레이아웃/인증 분리

---

## 플러그인 구조

```
etvibe-nextjs-fullstack/
├── .claude-plugin/
│   └── plugin.json           # 매니페스트
├── .mcp.json                 # MCP 서버 설정 (번들)
├── agents/                   # 커스텀 에이전트 (4개)
│   ├── dev-assistant.md
│   ├── architecture-expert.md
│   ├── performance-expert.md
│   └── docs-writer.md
├── commands/                 # 슬래시 명령어 (15개)
│   ├── code-review.md
│   ├── design-feature.md
│   ├── schema-design.md
│   ├── perf-audit.md
│   ├── refactor.md
│   ├── type-check.md
│   ├── waterfall-check.md
│   ├── task.md
│   ├── commit.md
│   ├── push.md
│   ├── pr.md
│   ├── generate-docs.md
│   ├── component-docs.md
│   ├── update-changelog.md
│   └── init.md
├── hooks/
│   └── hooks.json            # 자동화 훅 설정 (3개)
├── scripts/
│   ├── install-plugins.sh    # 외부 플러그인 설치
│   ├── check-typescript.sh   # TS 검사 훅 스크립트
│   ├── check-server-action.sh # Server Action 검증
│   └── check-prisma-schema.sh # Prisma 스키마 검증
└── skills/                   # 커스텀 스킬 (4개)
```

---

## 문제 해결

### MCP 연결 안 됨

```bash
# MCP 상태 확인
/mcp

# 플러그인 재설치
claude plugin uninstall etvibe-nextjs-fullstack
claude plugin install etvibe-nextjs-fullstack
```

### 에이전트가 인식 안 됨

```bash
# 에이전트 목록 확인
/agents

# Claude Code 재시작
```

### 외부 플러그인 누락

```bash
# 설치 스크립트 재실행
./scripts/install-plugins.sh
```

---

## 수동 설치 (스크립트 대신)

### 마켓플레이스 추가

```bash
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents
```

### Anthropic 공식 플러그인

```bash
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory
```

### 커뮤니티 플러그인

```bash
claude plugin install react-best-practices@agent-skills
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
```

### 옵셔널

```bash
claude plugin install frontend-design@claude-plugin-directory
claude plugin install web-design-guidelines@agent-skills
```

---

## 문서

| 문서 | 설명 |
|------|------|
| [커스터마이징 가이드](./docs/CUSTOMIZATION.md) | Hooks, Commands, Agents, Skills 확장 방법 |
| [개발 가이드](./docs/DEVELOPMENT.md) | 로컬 테스트, 디버깅, 배포 |
| [기여 가이드](./docs/CONTRIBUTING.md) | 브랜치 규칙, PR 프로세스, 코드 리뷰 |
| [브랜치 보호 설정](./github/BRANCH_PROTECTION.md) | GitHub 브랜치 보호 규칙 설정 |

---

## 기여하기

이 프로젝트에 기여하려면 [기여 가이드](./docs/CONTRIBUTING.md)를 참고하세요.

**주요 규칙:**
- `main` 브랜치 직접 커밋 금지 - PR 필수
- CODEOWNERS 승인 필요
- Conventional Commits 형식 사용

---

## 라이선스

MIT
