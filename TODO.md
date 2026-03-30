# TODO

etvibe-nextjs-fullstack 플러그인 로드맵
근거: [reports/PLUGIN-REVIEW-2025-02-25.md](reports/PLUGIN-REVIEW-2025-02-25.md) 섹션 14 팀 합의

---

## Phase 1: P0 즉시 수정 ✅

- [x] `--no-turbo` 플래그 제거 — 로컬 설정 수정 완료 (플러그인 범위 밖, gitignore 대상)
- [x] hooks 3개 → 1개 통합 (`post-write-check.sh`), 비관련 파일 즉시 exit 0
- [x] `.env` 커밋 방어 hook 추가 (exit 2 — 작업 중단)
- [x] `plugin.json` + `marketplace.json` description 영문 병기

## Phase 2: P1 보안/안정성 ✅

- [x] 권한 설정 축소 (`--force`, `-D` 등 destructive 명령 제외)
- [x] `claude:*` 와일드카드 → 명시적 allowlist
- [x] MCP 버전 고정 (`npx -y @latest` → `@x.y.z`)
- [x] Better Auth proxy.ts 패턴을 Next.js 16 표준으로 업데이트

## Phase 3: 기능 완결 (병렬) ✅

### 3-A. 테스트 패턴 ✅

- [x] 테스트 스킬 생성 (`skills/testing/SKILL.md`)
- [x] `/enf:test` 커맨드 추가
- [x] Vitest Unit Test 패턴
- [x] Testing Library 컴포넌트 테스트
- [x] Playwright E2E
- [x] Server Action 테스트 패턴

### 3-B. 트러블슈팅 가이드 ✅

- [x] `docs/TROUBLESHOOTING.md` 작성
- [x] 스킬 잘못된 코드 생성 시 롤백 방법
- [x] hooks 실패 시 우회 방법
- [x] MCP 연결 실패 시 수동 대체 방법

## Phase 4: 유통기한 관리 ✅

- [x] `COMPATIBILITY.md` — 지원 버전 매트릭스 (Next.js 16.x, Prisma 7.x, Better Auth ^1.4.0)
- [x] 각 스킬 상단에 `tested-with` 메타데이터 추가
- [x] `/enf:health` 커맨드 — 버전 호환성 자동 검증

## Phase 5: 워크플로우 고도화 ✅

- [x] 에이전트 핸드오프 프로토콜 정의 (architecture-expert → dev-assistant)
- [x] 에러 핸들링 / API Route 패턴 보강

## Phase 6-A: 영문화 (1.0 릴리즈용) ✅

Claude가 로드하는 파일을 영문 전환. 사용자 대면 문서(docs/, README 본문)는 한글 유지.

### Skills (6개)

- [x] `skills/prisma-7/SKILL.md`
- [x] `skills/better-auth/SKILL.md`
- [x] `skills/tailwind-v4-shadcn/SKILL.md`
- [x] `skills/coding-conventions/SKILL.md`
- [x] `skills/testing/SKILL.md`
- [x] `skills/error-handling/SKILL.md`

### Agents (4개)

- [x] `agents/dev-assistant.md`
- [x] `agents/architecture-expert.md` (Handoff Artifact 템플릿 포함)
- [x] `agents/performance-expert.md`
- [x] `agents/docs-writer.md`

### Commands (17개)

- [x] `commands/commit.md`
- [x] `commands/component-docs.md`
- [x] `commands/design-feature.md`
- [x] `commands/generate-docs.md`
- [x] `commands/health.md`
- [x] `commands/init.md`
- [x] `commands/perf-audit.md`
- [x] `commands/pr.md`
- [x] `commands/push.md`
- [x] `commands/refactor.md`
- [x] `commands/schema-design.md`
- [x] `commands/task.md`
- [x] `commands/test.md`
- [x] `commands/type-check.md`
- [x] `commands/update-changelog.md`
- [x] `commands/code-review.md`
- [x] `commands/waterfall-check.md`

### 기타

- [x] README.md 상단 한국어 안내 문구 추가
- [x] 영문화 검증 — frontmatter 무결성, triggers 한글+영문 병행, 코드 주석 한글 유지 확인
- [x] 팀 리뷰 피드백 반영 — design-feature.md 한글 인라인 예시 영문 전환, CONTRIBUTING.md i18n 규칙 문서화 (#16)

## Phase 7: 에이전트 & Hook 강화 (v1.2.0)

> 근거: gstack 역할 기반 에이전트 패턴 + Claude Code Hook 베스트 프랙티스

### 7-A. Agent skills 매핑 확대

- [x] `architecture-expert` → skills: `drizzle`, `better-auth`, `error-handling`
- [x] `dev-assistant` → skills: `coding-conventions`, `error-handling` 추가 (기존 `vercel-react-best-practices` 유지)
- [x] `performance-expert` → skills: `tailwind-v4-shadcn`
- [x] `docs-writer` → skills: `coding-conventions`

### 7-B. PostToolUse Hook 강화

- [x] `lucide-react` barrel import 감지 → 개별 import 권장 경고
- [x] `console.log` in production code 감지 → 제거 권장 경고
- [x] `page.tsx` + `route.ts` 같은 폴더 감지 → Next.js 충돌 경고

### 7-C. PreToolUse Hook (Safety Gate)

- [x] 위험 Bash 커맨드 감지 (drizzle-kit push, git push --force, git reset --hard, rm -rf)
- [x] prompt 타입 hook으로 사용자 확인 요청

## Phase 8: 통합 검증 커맨드 `/enf:validate` (v1.2.0) ✅

> 근거: PR 전 code-review + type-check + waterfall-check 반복 호출 비효율

- [x] `commands/validate.md` 생성
- [x] TypeScript strict 검증 (tsc --noEmit)
- [x] Waterfall 패턴 검출
- [x] Code Review (보안, 성능, 패턴)
- [x] PASS/FAIL 결과 요약 리포트

## Phase 9: 릴리즈 자동화 `/enf:release` (v1.3.0) ✅

> 근거: v1.1.1 릴리즈 시 plugin.json 미업데이트, CHANGELOG 중복, 수동 절차 실수

- [x] `commands/release.md` 생성
- [x] dev 브랜치 확인 + 최신 상태 검증
- [x] CHANGELOG [Unreleased] 확인
- [x] plugin.json version 자동 업데이트
- [x] 커밋 + push + Release PR 생성

## Phase 10: 워크플로우 체이닝 `/enf:flow` (v1.3.0) ✅

> 근거: gstack 순차 스킬 체이닝 + `.local.md` 상태 파일 패턴

- [x] `commands/flow.md` 생성
- [x] `.local/flow-state.md` 상태 관리
- [x] feature 플로우: task → design → implement → validate → commit → pr
- [x] fix 플로우: task → implement → validate → commit → pr
- [x] refactor 플로우: task → refactor → validate → commit → pr
- [x] resume 기능: 중단된 단계부터 재개

## Phase 6-B: 배포/모니터링 가이드 (v1.4.0)

- [ ] Vercel 배포 가이드
- [ ] Sentry 모니터링 가이드

## Phase 11: DB 마이그레이션 자동화 `/enf:migrate` (v1.5.0)

> ⚠️ 리스크 높음 — Phase 7~10 안정화 후 별도 진행

- [ ] `commands/migrate.md` 생성
- [ ] schema.ts 변경 감지 (git diff)
- [ ] drizzle-kit generate 실행 + SQL diff 표시
- [ ] 사용자 확인 후 push (로컬) / migrate (프로덕션)

## Phase 6-C: 모노레포 가이드 (v1.5.0+ 필요 시)

- [ ] 모노레포 가이드

---

## 1.0 릴리즈 게이트

Phase 1~5 + 6-A 완료 시 릴리즈 가능

| 조건 | 필수 |
|------|:----:|
| P0 해결 (hooks 통합, .env 방어) | ✅ |
| P1 해결 (권한 축소, proxy.ts) | ✅ |
| 보안 (.env 방어, MCP 고정) | ✅ |
| /enf:test 커맨드 | ✅ |
| TROUBLESHOOTING.md | ✅ |
| COMPATIBILITY.md | ✅ |
| plugin.json 영문 description | ✅ |
| Phase 6-A 영문화 (skills/agents/commands) | ✅ |

---

## Backlog (기존)

- [ ] 새 프로젝트 생성 스크립트 (`scripts/create.sh`)
- [ ] GUI 폴더 선택 다이얼로그
- [ ] 환경 변수 템플릿 생성 (`.env.example`)

---

## Done

- [x] 인터랙티브 프로젝트 경로 입력 모드 (2025-01-29)
- [x] Tab 자동완성 지원 - macOS/Linux (2025-01-29)
- [x] 플러그인 삭제 가이드 문서화 (2025-01-29)
- [x] Skills triggers 추가 (2026-02-25)
- [x] Tailwind v4 문법 검증 및 수정 (2026-02-25)
- [x] Agents 중복 제거 (2026-02-25)
- [x] hooks requireAuth 패턴 확장 (2026-02-25)
- [x] next-devtools 사용 조건 명시 (2026-02-25)
- [x] PR 타겟 --base dev 기본 명시 (2026-02-25)
- [x] code-review MCP/스킬 연동 (2026-02-25)
- [x] 브랜치 워크플로우 문서 강화 (2026-02-25)
- [x] Phase 1 P0: hooks 3→1 통합, .env exit 2 방어, 영문 병기 (2026-02-25)
- [x] Phase 2 P1: 권한 축소, claude:* 제거, MCP 버전 고정, proxy.ts Next.js 16 표준 업데이트 (2026-02-25)
- [x] Phase 3-A: 테스트 스킬 + /enf:test 커맨드 + 5개 문서 업데이트 (2026-02-25)
- [x] Phase 3-B: TROUBLESHOOTING.md 작성 — 롤백/hooks 우회/MCP 수동 대체 (2026-02-25)
- [x] Phase 4: COMPATIBILITY.md + tested-with 메타데이터 + /enf:health 커맨드 (2026-02-25)
- [x] Phase 5: error-handling 스킬 + Handoff Artifact 프로토콜 (2026-02-25)
- [x] Phase 6-A: 영문화 — Skills 6개 + Agents 4개 + Commands 17개 + README 안내 문구 (2026-02-25)
- [x] Phase 6-A 팀 리뷰 패치: design-feature.md 영문 전환 + CONTRIBUTING.md i18n 규칙 문서화 (2026-02-25)
