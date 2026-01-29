# etvibe-nextjs-fullstack

Next.js 16 + Prisma 7 + Better Auth 풀스택 개발을 위한 Claude Code 플러그인 패키지

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

## 빠른 시작

### 1. 설치

```bash
# 레포 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git
cd etvibe-nextjs-fullstack

# 외부 의존성 설치 (스크립트)
chmod +x scripts/install-dependencies.sh
./scripts/install-dependencies.sh
```

### 2. 프로젝트에 적용

```bash
# 프로젝트 디렉토리로 이동
cd your-project

# agents, skills 폴더를 .claude/ 에 복사
cp -r /path/to/etvibe-nextjs-fullstack/agents .claude/
cp -r /path/to/etvibe-nextjs-fullstack/skills .claude/
```

### 3. 확인

```bash
# Claude Code 실행
claude

# 에이전트 목록 확인
/agents
```

---

## 주요 기능 및 사용법

### Git 워크플로우

| 작업 | 명령어 | 설명 |
|------|--------|------|
| **커밋 생성** | `/commit` | 변경사항 분석 후 컨벤션에 맞는 커밋 메시지 생성 |
| **PR 리뷰** | `/review-pr` | 보안/타입/성능 등 6가지 관점으로 PR 리뷰 |
| **PR 생성** | "PR 생성해줘" | 브랜치 비교 후 PR 생성 |

**커밋 컨벤션 (coding-conventions 스킬):**
```
<type>: <한글 설명>

feat: 새 기능
fix: 버그 수정
refactor: 리팩토링
test: 테스트
docs: 문서
style: 포맷팅
chore: 빌드/설정
```

**예시:**
```bash
# Claude Code에서
> /commit
# → 변경사항 분석 후 "feat: 고객 목록 페이지 추가" 같은 커밋 생성

> /review-pr
# → 현재 PR의 보안, 타입 안전성, 성능 등 리뷰
```

---

### 개발 작업

| 작업 | 명령어/프롬프트 | 담당 에이전트/스킬 |
|------|----------------|-------------------|
| **기능 개발** | "로그인 기능 구현해줘" | dev-assistant + feature-dev |
| **폼 생성** | "고객 등록 폼 만들어줘" | tailwind-v4-shadcn 스킬 |
| **인증 구현** | "Better Auth 세션 체크 추가해줘" | better-auth 스킬 |
| **DB 작업** | "Customer 모델에 status 필드 추가해줘" | prisma-7 스킬 |
| **코드 리뷰** | "이 파일 리뷰해줘" | dev-assistant |
| **리팩토링** | "이 컴포넌트 Server Component로 변환해줘" | dev-assistant |

**예시 - 폼 생성:**
```
> "고객 등록 폼을 shadcn/ui로 만들어줘. 이름, 이메일, 전화번호 필드 필요해"

→ React Hook Form + Zod 검증이 포함된 폼 컴포넌트 생성
```

**예시 - Server Action:**
```
> "고객 수정 Server Action 만들어줘"

→ 인증 체크, Zod 검증, Prisma 쿼리, revalidatePath 포함된 액션 생성
```

---

### 테스트

| 작업 | 명령어/프롬프트 | 담당 |
|------|----------------|------|
| **E2E 테스트 작성** | "로그인 페이지 E2E 테스트 작성해줘" | Playwright |
| **E2E 테스트 실행** | "Playwright 테스트 실행해줘" | Playwright |
| **테스트 디버깅** | "이 테스트 왜 실패하는지 분석해줘" | Playwright |

**예시:**
```
> "관리자 로그인 → 고객 목록 → 고객 상세 이동하는 E2E 테스트 만들어줘"

→ Playwright 테스트 파일 생성 및 실행
```

---

### 성능 최적화

| 작업 | 명령어/프롬프트 | 담당 |
|------|----------------|------|
| **성능 분석** | "이 페이지 성능 분석해줘" | performance-expert |
| **번들 분석** | "번들 크기 확인해줘" | performance-expert |
| **Core Web Vitals** | "LCP 개선 방법 알려줘" | performance-expert |

**성능 체크리스트 (dev-assistant 자동 적용):**
- [ ] 순차 await 3개 이상 → Promise.all() 검토
- [ ] 모달/에디터/차트 → dynamic import
- [ ] lucide-react 아이콘 → 개별 import
- [ ] RSC → CC 경계 → 최소 데이터 전달

---

### 설계 & 아키텍처

| 작업 | 명령어/프롬프트 | 담당 |
|------|----------------|------|
| **기능 설계** | "캠페인 관리 기능 설계해줘" | architecture-expert |
| **스키마 설계** | "캠페인-인플루언서 관계 설계해줘" | architecture-expert |
| **라우팅 설계** | "마이페이지 URL 구조 제안해줘" | architecture-expert |

**예시:**
```
> "새로운 '문의 관리' 기능 추가하려는데 설계해줘"

→ 라우팅, 데이터 모델, 컴포넌트 구조, API 패턴 제안
```

---

### 문서 작성

| 작업 | 명령어/프롬프트 | 담당 |
|------|----------------|------|
| **README 작성** | "이 프로젝트 README 작성해줘" | docs-writer |
| **API 문서** | "이 Server Action 문서화해줘" | docs-writer |
| **컴포넌트 문서** | "이 컴포넌트 사용법 문서 만들어줘" | docs-writer |

---

### 보안 검사

| 작업 | 명령어/프롬프트 | 담당 |
|------|----------------|------|
| **보안 검사** | "이 코드 보안 검사해줘" | security-guidance |
| **취약점 분석** | "SQL 인젝션 가능성 확인해줘" | security-guidance |

---

## 패키지 구성 상세

### 커스텀 에이전트 (4개)

#### dev-assistant
- **역할**: 일상적인 개발 작업 지원
- **주요 기능**: 코드 리뷰, 리팩토링, TypeScript 타입 검증
- **사용 MCP**: context7 (라이브러리 문서 조회)

#### architecture-expert
- **역할**: 설계 전문가 (구현 X, 설계만)
- **주요 기능**: 시스템 설계, 데이터 모델링, 라우팅 구조 결정
- **사용 MCP**: context7, next-devtools

#### performance-expert
- **역할**: 성능 최적화 전문가
- **주요 기능**: Core Web Vitals 개선, 번들 분석
- **사용 MCP**: next-devtools (browser_eval)

#### docs-writer
- **역할**: 기술 문서 작성
- **주요 기능**: README, API 문서, 컴포넌트 문서
- **사용 MCP**: context7

### 커스텀 스킬 (4개)

#### coding-conventions
- 네이밍 규칙 (PascalCase, camelCase, kebab-case)
- Import 순서 규칙
- Git 커밋 컨벤션
- TypeScript 규칙 (any 금지, unknown 사용)

#### tailwind-v4-shadcn
- Tailwind CSS v4 변경사항 (@theme 디렉티브)
- shadcn/ui 폼 패턴 (React Hook Form + Zod)
- Server Action과 함께 사용하는 패턴

#### better-auth
- Better Auth 설정 패턴
- Server Component/Action에서 세션 확인
- 역할 기반 접근 제어 (RBAC)

#### prisma-7
- Prisma 7 Breaking Changes (prisma.config.ts, pg adapter)
- 쿼리 최적화 패턴 (select, include, N+1 방지)
- 트랜잭션 패턴

### 외부 플러그인 (설치 필요)

| 플러그인 | 출처 | 용도 | 명령어 |
|---------|------|------|--------|
| Playwright | Anthropic | E2E 테스트 | - |
| pr-review-toolkit | Anthropic | PR 리뷰 | `/review-pr` |
| commit-commands | Anthropic | 커밋 생성 | `/commit` |
| feature-dev | Anthropic | 기능 개발 | - |
| security-guidance | Anthropic | 보안 검사 | - |
| react-best-practices | Vercel Labs | React 최적화 | 자동 적용 |
| next-best-practices | Vercel Labs | Next.js 지식 | `/next-upgrade` |
| javascript-typescript | wshobson | JS/TS 전문가 | - |
| database-design | wshobson | 스키마 설계 | - |

### 외부 플러그인 - 옵셔널

| 플러그인 | 출처 | 용도 | 명령어 |
|---------|------|------|--------|
| frontend-design | Anthropic | 고품질 UI | - |
| web-design-guidelines | Vercel Labs | 접근성/UX 감사 | `/web-design-guidelines` |

### MCP 서버 (설치 필요)

| MCP | 용도 | 사용하는 에이전트 |
|-----|------|------------------|
| context7 | 라이브러리 최신 문서 조회 | dev-assistant, docs-writer |
| next-devtools | Next.js 개발 서버 연동 | architecture-expert, performance-expert |
| prisma-local | 마이그레이션, Prisma Studio | - |

---

## 수동 설치 (스크립트 대신)

### Step 1: MCP 서버

```bash
# context7 - 라이브러리 문서 조회 (에이전트 필수)
claude mcp add context7 -- npx -y @anthropic-ai/context7-mcp@latest

# next-devtools - Next.js 개발 서버 연동 (에이전트 필수)
claude mcp add next-devtools -- npx -y @anthropic-ai/next-devtools-mcp@latest

# prisma-local - 마이그레이션/Studio
claude mcp add prisma-local -- npx prisma mcp
```

### Step 2: 마켓플레이스

```bash
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents
```

### Step 3: Anthropic 공식 플러그인

```bash
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory
```

### Step 4: Vercel Labs 스킬

```bash
npx skills add vercel-labs/next-skills
claude plugin install react-best-practices@agent-skills
```

### Step 5: wshobson 플러그인

```bash
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
```

### Step 6: 옵셔널

```bash
# 고품질 UI 디자인 원할 때
claude plugin install frontend-design@claude-plugin-directory

# 접근성/UX 감사 원할 때
claude plugin install web-design-guidelines@agent-skills
```

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
- `_` prefix 폴더는 Next.js 라우팅에서 제외됨 (Private Folders)
- 관련 코드는 한 곳에 모으기 (Co-location)
- `(group)` Route Group으로 레이아웃/인증 분리

---

## 문제 해결

### MCP 연결 안 됨

```bash
# MCP 상태 확인
claude mcp list

# MCP 재설치
claude mcp remove context7
claude mcp add context7 -- npx -y @anthropic-ai/context7-mcp@latest
```

### 에이전트가 인식 안 됨

```bash
# .claude/agents/ 폴더 확인
ls -la .claude/agents/

# 파일 형식 확인 (YAML frontmatter 필수)
head -10 .claude/agents/dev-assistant.md
```

### 스킬이 적용 안 됨

```bash
# .claude/skills/ 폴더 확인
ls -la .claude/skills/

# Claude Code 재시작
```

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
