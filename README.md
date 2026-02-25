<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-5A67D8?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code Plugin" />
  <img src="https://img.shields.io/badge/Next.js-16-000000?style=for-the-badge&logo=next.js&logoColor=white" alt="Next.js 16" />
  <img src="https://img.shields.io/badge/Prisma-7-2D3748?style=for-the-badge&logo=prisma&logoColor=white" alt="Prisma 7" />
  <img src="https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
</p>

# etvibe-nextjs-fullstack

> **AI-First 풀스택 개발 워크플로우**
> Next.js 16 + Prisma 7 + Better Auth 프로젝트를 위한 Claude Code 플러그인

```
Plugin Name: enf
Namespace:   /enf:command (예: /enf:commit, /enf:code-review)
```

---

## Why This Plugin?

| 문제 | 해결 |
|------|------|
| 팀마다 다른 코드 스타일 | **5개 Skills**로 컨벤션 자동 적용 |
| 반복되는 보일러플레이트 | **16개 Commands**로 워크플로우 자동화 |
| 기술 스택 학습 곡선 | **4개 Agents**가 베스트 프랙티스 가이드 |
| 코드 리뷰 병목 | AI 기반 사전 리뷰로 품질 향상 |

---

## Quick Start

```bash
# 1. Clone (최초 1회)
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git ~/plugins/enf

# 2. Setup (플러그인 디렉토리에서 실행)
cd ~/plugins/enf
chmod +x scripts/setup.sh
./scripts/setup.sh              # 인터랙티브 모드 (Tab 자동완성 지원)
# 또는
./scripts/setup.sh ~/projects/my-app  # 직접 경로 지정

# 3. Use
cd ~/projects/my-app && claude
```

```bash
# 확인
/agents      # 에이전트 목록
/enf:init    # 플러그인 가이드
```

<details>
<summary><b>Windows (PowerShell)</b></summary>

```powershell
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git C:\plugins\enf
cd C:\plugins\enf
.\scripts\setup.ps1 C:\projects\my-app   # 직접 경로 지정 권장 (Tab 완성 지원)
# 또는
.\scripts\setup.ps1                      # 인터랙티브 모드 (Tab 완성 미지원)
```
</details>

---

## Tech Stack

| 기술 | 버전 | 용도 |
|:-----|:----:|------|
| **Next.js** | 16.x | App Router + Turbopack |
| **React** | 19.x | Server Components 우선 |
| **Prisma** | 7.x | PostgreSQL + pg adapter |
| **Better Auth** | 1.4.x | 세션 기반 인증 |
| **Tailwind CSS** | 4.x | CSS-first 설정 |
| **shadcn/ui** | latest | Radix 기반 컴포넌트 |

---

## What's Included

### Agents (4)

역할별 전문 AI 에이전트가 개발을 지원합니다.

| Agent | 역할 | 특징 |
|-------|------|------|
| **dev-assistant** | 코드 구현/리뷰/리팩토링 | Write/Edit 가능, context7 연동 |
| **architecture-expert** | 시스템 설계/데이터 모델링 | 설계만 담당 (구현 X) |
| **performance-expert** | 번들 분석/Core Web Vitals | next-devtools 연동 |
| **docs-writer** | API/컴포넌트 문서 생성 | 템플릿 기반 자동화 |

### Commands (16)

모든 명령어는 `/enf:` 네임스페이스를 사용합니다.

| 구분 | Command | 설명 |
|:----:|---------|------|
| **Core** | `code-review` | TypeScript, 성능, 보안 관점의 코드 품질 검사 |
| | `design-feature` | 새 기능의 아키텍처 설계 (Route, Model, API) |
| | `schema-design` | Prisma 스키마 설계 및 리뷰 |
| | `perf-audit` | 번들 크기, Waterfall, Core Web Vitals 분석 |
| **Dev** | `refactor` | 코드 리팩토링 제안 및 적용 |
| | `type-check` | TypeScript strict 모드 검증 |
| | `waterfall-check` | 순차 await 패턴 검출 → Promise.all 제안 |
| **Git** | `task` | 업무 정의 → 브랜치 자동 생성 |
| | `commit` | Conventional Commits 형식 커밋 |
| | `push` | 안전 체크 후 원격 저장소 푸시 |
| | `pr` | GitHub PR 생성 (템플릿 자동 적용) |
| **Docs** | `generate-docs` | Server Action/API 문서 자동 생성 |
| | `component-docs` | 컴포넌트 Props 문서 생성 |
| | `update-changelog` | CHANGELOG.md 자동 업데이트 |
| **진단** | `health` | 프로젝트 버전 호환성 검사 |
| **Guide** | `init` | 플러그인 사용법 및 프로젝트 가이드 |

### Skills (5)

키워드 기반으로 자동 활성화되는 지식 베이스입니다.

| Skill | 활성화 키워드 | 내용 |
|-------|--------------|------|
| **coding-conventions** | 컨벤션, 네이밍 | Import 순서, 네이밍 규칙, 커밋 메시지 |
| **better-auth** | 인증, 로그인, 세션 | 세션 관리, RBAC, Server Action 통합 |
| **prisma-7** | Prisma, 스키마, DB | v7 설정, pg adapter, 쿼리 패턴 |
| **tailwind-v4-shadcn** | Tailwind, shadcn, 폼 | CSS-first 설정, Form 패턴, 테마 |
| **testing** | 테스트, vitest, playwright | Vitest, Testing Library, Playwright E2E |

### MCP Servers (3)

| 서버 | 용도 |
|------|------|
| **context7** | Next.js, Prisma 등 라이브러리 최신 문서 조회 |
| **next-devtools** | Next.js 개발 서버 연동 (라우트, 에러 분석) |
| **prisma-local** | Prisma CLI 연동 (마이그레이션, Studio) |

---

## Bundled Plugins

셋업 스크립트가 자동으로 설치하는 검증된 플러그인 모음입니다.

### Anthropic Official

| 플러그인 | 용도 |
|---------|------|
| **playwright** | Playwright 기반 E2E 테스트 작성/실행 |
| **pr-review-toolkit** | 6가지 관점의 PR 코드 리뷰 (`/review-pr`) |
| **commit-commands** | 변경사항 분석 기반 커밋 메시지 생성 (`/commit`) |
| **feature-dev** | 기능 개발 워크플로우 가이드 |
| **security-guidance** | OWASP Top 10 기반 보안 취약점 검사 |
| **context7** | 라이브러리 공식 문서 실시간 조회 |
| **frontend-design** | 고품질 프론트엔드 UI 디자인 생성 |
| **code-review** | 자동 코드 리뷰 및 개선 제안 |

### Community

| 플러그인 | 출처 | 용도 |
|---------|------|------|
| **javascript-typescript** | wshobson/agents | JS/TS 고급 패턴 및 최적화 가이드 |
| **database-design** | wshobson/agents | 데이터베이스 스키마 설계 전문가 |

---

## Workflow

```
/enf:task "기능명"          →  브랜치 생성
       ↓
/enf:design-feature         →  아키텍처 설계 (선택)
       ↓
    [구현]                   →  dev-assistant
       ↓
/enf:code-review            →  품질 검사
       ↓
/enf:commit → /enf:push → /enf:pr
```

---

## Documentation

| 문서 | 설명 |
|------|------|
| **[Team Onboarding](./docs/TEAM-ONBOARDING.md)** | 신규 팀원 빠른 시작 |
| [Commands Reference](./docs/COMMANDS-REFERENCE.md) | 커맨드 빠른 참조 |
| [Installation](./docs/INSTALLATION.md) | 상세 설치 및 문제 해결 |
| [Guidelines](./docs/GUIDELINES.md) | 플러그인 철학 및 워크플로우 |
| [Customization](./docs/CUSTOMIZATION.md) | 플러그인 확장 가이드 |
| [Agents Manual](./docs/AGENTS-MANUAL.md) | 에이전트 상세 사용법 |
| [Scenario Guides](./docs/SCENARIO-GUIDES.md) | 상황별 워크플로우 |
| [Compatibility](./docs/COMPATIBILITY.md) | 지원 버전 매트릭스 |
| [CHANGELOG](./CHANGELOG.md) | 버전 이력 |

---

## Update

```bash
cd ~/plugins/enf
git pull origin main
./scripts/setup.sh
```

---

<p align="center">
  <sub>Built with Claude Code by <b>etvibe</b> AI Team</sub>
</p>

## License

MIT
