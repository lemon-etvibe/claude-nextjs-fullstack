# TODO

etvibe-nextjs-fullstack 플러그인 로드맵
근거: [reports/PLUGIN-REVIEW-2025-02-25.md](reports/PLUGIN-REVIEW-2025-02-25.md) 섹션 14 팀 합의

---

## Phase 1: P0 즉시 수정

- [ ] `--no-turbo` 플래그 제거 (`.claude/settings.local.json`)
- [ ] hooks 패턴을 `src/**/*.{ts,tsx}`, `prisma/schema.prisma`로 제한
- [ ] `.env` 커밋 방어 hook 추가
- [ ] `plugin.json` description 영문 병기

## Phase 2: P1 보안/안정성

- [ ] 권한 설정 축소 (`--force`, `-D` 등 destructive 명령 제외)
- [ ] `claude:*` 와일드카드 → 명시적 allowlist
- [ ] MCP 버전 고정 (`npx -y @latest` → `@x.y.z`)
- [ ] Better Auth proxy.ts → API Route handler 업데이트

## Phase 3: 기능 완결 (병렬)

### 3-A. 테스트 패턴

- [ ] 테스트 스킬 생성 (`skills/testing/SKILL.md`)
- [ ] `/enf:test` 커맨드 추가
- [ ] Vitest Unit Test 패턴
- [ ] Testing Library 컴포넌트 테스트
- [ ] Playwright E2E
- [ ] Server Action 테스트 패턴

### 3-B. 트러블슈팅 가이드

- [ ] `docs/TROUBLESHOOTING.md` 작성
- [ ] 스킬 잘못된 코드 생성 시 롤백 방법
- [ ] hooks 실패 시 우회 방법
- [ ] MCP 연결 실패 시 수동 대체 방법

## Phase 4: 유통기한 관리

- [ ] `COMPATIBILITY.md` — 지원 버전 매트릭스 (Next.js 16.x, Prisma 7.x, Better Auth ^1.4.0)
- [ ] 각 스킬 상단에 `tested-with` 메타데이터 추가
- [ ] `/enf:health` 커맨드 — 버전 호환성 자동 검증

## Phase 5: 워크플로우 고도화

- [ ] 에이전트 핸드오프 프로토콜 정의 (architecture-expert → dev-assistant)
- [ ] 에러 핸들링 / API Route 패턴 보강

## Phase 6: 확장

- [ ] 영문화 (README, SKILL 4개, COMMANDS-REFERENCE)
- [ ] 배포/모니터링 가이드 (Vercel, Sentry)
- [ ] 모노레포 가이드 (필요 시)

---

## 1.0 릴리즈 게이트

Phase 1~4 완료 시 릴리즈 가능

| 조건 | 필수 |
|------|:----:|
| P0 해결 (--no-turbo, hooks) | O |
| P1 해결 (권한 축소, proxy.ts) | O |
| 보안 (.env 방어, MCP 고정) | O |
| /enf:test 커맨드 | O |
| TROUBLESHOOTING.md | O |
| COMPATIBILITY.md | O |
| plugin.json 영문 description | O |

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
