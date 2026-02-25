# Changelog

이 프로젝트의 모든 주요 변경사항을 기록합니다.
형식: [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)

---

## [Unreleased]

### Added
- **i18n**: Phase 6-A 영문화 — skills/agents/commands 영문 전환 (#15)
- **workflow**: Phase 5 워크플로우 고도화 (#14)
- **compatibility**: Phase 4 유통기한 관리 (#13)
- **testing**: Phase 3-A 테스트 패턴 스킬 및 커맨드 추가 (#11)
- **compatibility**: Phase 4 유통기한 관리 — COMPATIBILITY.md, tested-with 메타데이터, /enf:health 커맨드
- **error-handling**: Phase 5 에러 핸들링 스킬 추가 — Server Action, API Route, Prisma, Error Boundary 패턴
- **workflow**: Phase 5 에이전트 핸드오프 프로토콜 정의 — Handoff Artifact 형식, design-feature 출력 강화
- **i18n**: Phase 6-A 영문화 — Skills 6개, Agents 4개, Commands 17개 영문 전환 (#15)
- **i18n**: README.md 상단 한국어 안내 문구 추가
- **i18n**: triggers에 영문 키워드 추가 (한글 키워드 유지)

### Changed
- **troubleshooting**: Phase 3-B 트러블슈팅 가이드 추가 (#12)
- **i18n**: frontmatter description 영문 전환 (skills/agents/commands 전체)

### Fixed
- **i18n**: translate Korean inline example and document translation rules (#16)
- (버그 수정 시 여기에 기록)

---

## [0.9.1] - 2026-02-25

Phase 1 P0 + Phase 2 P1 보안/안정성 수정.

### Changed
- 문서 구조 개선 및 COMMANDS-REFERENCE 추가 (#5)
- **better-auth**: proxy.ts 패턴을 Next.js 16 표준으로 업데이트 — `middleware()` → `proxy()`, Edge → Node.js Runtime (#10)
- **docs**: DEVELOPMENT.md에 권장 권한 설정 가이드 추가 (#10)

### Fixed
- **hooks**: P0 — hooks 3개→1개 통합, .env 커밋 방어 (exit 2), 영문 설명 추가 (#9)
- **mcp**: 패키지명 수정 및 버전 고정 — `@upstash/context7-mcp@2.1.2`, `next-devtools-mcp@0.3.10` (기존 패키지명 npm 미존재) (#10)
- **security**: 권한 설정 축소 — `claude:*` 와일드카드 제거, `git branch -D`/`git push --force` 차단 (#10)

---

## [0.9.0] - 2025-01-30

프리릴리즈. Next.js 16 + Prisma 7 + Better Auth 풀스택 개발을 위한 Claude Code 플러그인.

### Added
- 인터랙티브 프로젝트 경로 입력 모드 (`scripts/setup.sh`, `scripts/setup.ps1`)
- Tab 자동완성 지원 (macOS/Linux)
- 플러그인 삭제 가이드 (`docs/INSTALLATION.md`)
- TODO.md 로드맵 문서

### Changed
- 셋업 스크립트를 플러그인 디렉토리에서 실행하도록 워크플로우 변경
- 설치 문서 전면 개편

---

## [0.1.0] - 2025-01-29

최초 개발 버전.

### Added

#### Agents (4개)

| Agent | 역할 | Write/Edit |
|-------|------|:----------:|
| `dev-assistant` | 코드 구현, 리뷰, 리팩토링 | O |
| `architecture-expert` | 시스템 설계 (구현 안함) | X |
| `performance-expert` | 성능 분석, 번들 최적화 | O |
| `docs-writer` | 문서 작성 | O |

#### Skills (4개)

| Skill | 활성화 키워드 |
|-------|--------------|
| `coding-conventions` | 컨벤션, 네이밍, 코드 스타일 |
| `better-auth` | 인증, 세션, 로그인, Better Auth |
| `prisma-7` | Prisma, 스키마, 마이그레이션 |
| `tailwind-v4-shadcn` | Tailwind, shadcn, 폼, 스타일 |

#### Commands (15개)

**핵심**
- `/enf:code-review` - 코드 품질 검사 (TypeScript, 성능, 보안)
- `/enf:design-feature` - 새 기능 아키텍처 설계
- `/enf:schema-design` - Prisma 스키마 설계/리뷰
- `/enf:perf-audit` - 성능 분석 (번들, Core Web Vitals)

**개발**
- `/enf:refactor` - 코드 리팩토링 제안
- `/enf:type-check` - TypeScript 타입 검증
- `/enf:waterfall-check` - 순차 await 패턴 검출

**Git**
- `/enf:task` - 업무 정의 및 Git 브랜치 생성
- `/enf:commit` - Conventional Commits 형식 커밋
- `/enf:push` - 원격 저장소 푸시 (안전 체크)
- `/enf:pr` - GitHub PR 생성 (자동 템플릿)

**문서**
- `/enf:generate-docs` - API/Server Action 문서 생성
- `/enf:component-docs` - 컴포넌트 Props 문서 생성
- `/enf:update-changelog` - CHANGELOG.md 업데이트

**가이드**
- `/enf:init` - 프로젝트 구조 및 개발 가이드

#### MCP Servers (3개)

| 서버 | 용도 |
|------|------|
| `context7` | 라이브러리 문서 조회 (Next.js, Prisma 등) |
| `next-devtools` | Next.js 개발 서버 연동 (라우트, 에러 분석) |
| `prisma-local` | Prisma 마이그레이션, Studio 실행 |

#### Hooks (3개)

| Hook | 트리거 | 동작 |
|------|--------|------|
| TypeScript 검사 | `.ts/.tsx` 저장 | lint/type 체크 안내 |
| Server Action 검증 | `_actions/*.ts` 저장 | 인증 패턴, `use server` 확인 |
| Prisma 스키마 검증 | `schema.prisma` 수정 | 마이그레이션 절차 안내 |

#### 외부 플러그인 (셋업 스크립트로 설치)

**Anthropic 공식**
- playwright, pr-review-toolkit, commit-commands
- feature-dev, security-guidance, context7
- frontend-design, code-review

**커뮤니티 (wshobson/agents)**
- javascript-typescript, database-design

#### 문서

- README.md - 빠른 시작 가이드
- docs/INSTALLATION.md - 상세 설치 가이드
- docs/CUSTOMIZATION.md - 확장 가이드
- docs/DEVELOPMENT.md - 개발 가이드
- docs/CONTRIBUTING.md - 기여 가이드
- docs/GUIDELINES.md - 플러그인 철학 및 가이드라인
- docs/TEAM-ONBOARDING.md - 팀 온보딩 가이드
- docs/AGENTS-MANUAL.md - 에이전트 매뉴얼
- docs/SCENARIO-GUIDES.md - 시나리오별 가이드
- docs/SKILLS-ACTIVATION.md - 스킬 활성화 가이드

---

## 버전 규칙

- **MAJOR**: 호환되지 않는 API 변경
- **MINOR**: 하위 호환되는 기능 추가
- **PATCH**: 하위 호환되는 버그 수정

## 링크

- [README](./README.md)
- [설치 가이드](./docs/INSTALLATION.md)
- [기여 가이드](./docs/CONTRIBUTING.md)
