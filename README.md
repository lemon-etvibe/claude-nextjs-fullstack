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

## 빠른 시작

### Windows (PowerShell)

```powershell
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git C:\plugins\enf

# 2. 셋업 스크립트 실행 (플러그인 설치 + alias 등록)
cd C:\plugins\enf
.\scripts\setup.ps1

# 3. 새 PowerShell 창에서 프로젝트로 이동 후 사용
cd C:\projects\my-nextjs-app
claude-enf
```

### macOS/Linux

```bash
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git ~/plugins/enf

# 2. 셋업 스크립트 실행 (플러그인 설치 + alias 등록)
cd ~/plugins/enf
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. 새 터미널에서 프로젝트로 이동 후 사용
cd ~/projects/my-nextjs-app
claude-enf
```

### 확인

```bash
/agents    # 에이전트 목록
/mcp       # MCP 서버 상태
/enf:init  # 플러그인 초기화 가이드
```

### 플러그인 업데이트

```bash
cd ~/plugins/enf  # 또는 C:\plugins\enf
git pull origin main
```

---

## 패키지 구성

### 번들 포함 (자동 설정)

| 구성 요소 | 내용 |
|----------|------|
| **에이전트** | dev-assistant, architecture-expert, performance-expert, docs-writer |
| **스킬** | coding-conventions, better-auth, prisma-7, tailwind-v4-shadcn |
| **MCP 서버** | context7, next-devtools, prisma-local |

### 외부 플러그인 (셋업 스크립트로 설치)

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

---

## 주요 기능

### Commands (15개)

> 모든 Commands는 `/enf:` 접두사 사용

| 카테고리 | Command | 설명 |
|---------|---------|------|
| **핵심** | `/enf:code-review` | 코드 품질 검사 (TypeScript, 성능, 보안) |
| | `/enf:design-feature` | 새 기능 아키텍처 설계 |
| | `/enf:schema-design` | Prisma 스키마 설계/리뷰 |
| | `/enf:perf-audit` | 성능 분석 (번들, Core Web Vitals) |
| **개발** | `/enf:refactor` | 코드 리팩토링 제안 |
| | `/enf:type-check` | TypeScript 타입 검증 |
| | `/enf:waterfall-check` | 순차 await 패턴 → Promise.all 제안 |
| **Git** | `/enf:task` | 업무 정의 → Git 브랜치 생성 |
| | `/enf:commit` | Conventional Commits 형식 커밋 |
| | `/enf:push` | 원격 저장소 푸시 (안전 체크) |
| | `/enf:pr` | GitHub PR 생성 (자동 템플릿) |
| **문서** | `/enf:generate-docs` | API/Server Action 문서 생성 |
| | `/enf:component-docs` | 컴포넌트 Props 문서 생성 |
| | `/enf:update-changelog` | CHANGELOG.md 업데이트 |
| **가이드** | `/enf:init` | 프로젝트 구조 및 개발 가이드 |

### Hooks (3개)

| Hook | 트리거 | 동작 |
|------|--------|------|
| TypeScript 검사 | `.ts/.tsx` 저장 | lint/type 체크 안내 |
| Server Action 검증 | `_actions/*.ts` 저장 | 인증 패턴, `use server` 확인 |
| Prisma 스키마 검증 | `schema.prisma` 수정 | 마이그레이션 절차 안내 |

---

## 워크플로우 예시

```bash
# 1. 작업 시작 (브랜치 생성)
/enf:task "고객 검색 기능 구현"

# 2. 기능 설계 (복잡한 경우)
/enf:design-feature "고객 검색 필터 및 정렬"

# 3. 코드 리뷰
/enf:code-review src/app/(admin)/_actions/customer.ts

# 4. 커밋 및 PR
/commit  # 또는 /enf:commit
/enf:pr
```

---

## 문서

| 문서 | 설명 |
|------|------|
| [설치 가이드](./docs/INSTALLATION.md) | 상세 설치, Shell alias, 글로벌 설정, 문제 해결 |
| [커스터마이징 가이드](./docs/CUSTOMIZATION.md) | Hooks, Commands, Agents, Skills 확장 |
| [개발 가이드](./docs/DEVELOPMENT.md) | 로컬 테스트, 디버깅, 배포 |
| [기여 가이드](./docs/CONTRIBUTING.md) | 브랜치 규칙, PR 프로세스 |
| [브랜치 보호 설정](./github/BRANCH_PROTECTION.md) | GitHub 브랜치 보호 규칙 |

---

## 라이선스

MIT
