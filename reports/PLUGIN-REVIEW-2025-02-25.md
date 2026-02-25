# ENF Plugin Review Report

etvibe-nextjs-fullstack (v0.9.0) 종합 리뷰 리포트

- 작성일: 2025-02-25
- 작성: Claude Opus 4 + lemon-etvibe
- 범위: Skills, Agents, Commands, Config, Docs 전체

---

## 1. 종합 평가

| 항목 | 점수 | 요약 |
|------|------|------|
| 품질 (Quality) | 8.0/10 | 구조화 잘 되어있고 실전 노하우가 녹아있음 |
| 완성도 (Completeness) | 7.0/10 | 핵심 개발 영역은 커버, 테스트/배포/모니터링 부재 |
| 일관성 (Consistency) | 7.5/10 | 네이밍은 통일, 문서 포맷/에러 처리 패턴은 불균일 |
| 효과성 (Effectiveness) | 8.5/10 | 프롬프트 품질 높고 실사용 시 좋은 결과 기대 |
| 기술 정확성 (Accuracy) | 8.0/10 | 일부 구식 패턴 존재 (Better Auth proxy 등) |
| 확장성 (Extensibility) | 6.5/10 | 마크다운 직접 수정만 가능, 구성 override 미지원 |
| **종합** | **7.7/10** | **실전 투입 가능, 핵심 버그 수정 및 영역 확장 필요** |

---

## 2. 현재 구성 요약

### 2.1 에이전트 (4개)

| Agent | 역할 | Write/Edit | 평가 |
|-------|------|:----------:|------|
| dev-assistant | 코드 구현, 리뷰, 리팩토링 | O | 8.5/10 — 가장 완성도 높음 |
| architecture-expert | 시스템 설계 (구현 안함) | X | 9.0/10 — Co-location, 워터폴 방지 우수 |
| performance-expert | 성능 분석, 번들 최적화 | O | 7.5/10 — CWV 타겟 일반적, 모니터링 부재 |
| docs-writer | 문서 작성 | O | 8.0/10 — API 문서 강점, 테스트 문서 없음 |

### 2.2 스킬 (4개)

| Skill | 트리거 키워드 | 커버리지 | 주요 누락 |
|-------|-------------|----------|-----------|
| coding-conventions | 컨벤션, 네이밍, 코드 스타일 | 85% | API Route 패턴, 에러 핸들링 |
| better-auth | 인증, 세션, 로그인 | 80% | 2FA/MFA, 소셜 로그인, proxy.ts 구식 |
| prisma-7 | Prisma, 스키마, 마이그레이션 | 75% | 소프트 딜리트 전략, 마이그레이션 충돌 해결 |
| tailwind-v4-shadcn | Tailwind, shadcn, 폼 | 90% | 다크모드 엣지케이스 |

### 2.3 커맨드 (15개)

- 핵심 (4): code-review, design-feature, schema-design, perf-audit
- 개발 최적화 (3): refactor, type-check, waterfall-check
- Git 워크플로우 (4): task, commit, push, pr
- 문서화 (3): generate-docs, component-docs, update-changelog
- 가이드 (1): init

### 2.4 MCP 서버 (3개)

context7 (라이브러리 문서), next-devtools (개발 서버), prisma-local (Prisma CLI)

---

## 3. 크리티컬 이슈 (즉시 수정 필요)

### 3.1 Better Auth 미들웨어 패턴 구식화

- 파일: `skills/better-auth/SKILL.md`
- 문제: proxy.ts 미들웨어 패턴이 Better Auth 1.4.x에서 deprecated
- 영향: `/enf:init` 등으로 프로젝트 설정 시 처음부터 구식 코드 생성
- 수정: API Route handler 패턴으로 업데이트 필요

### 3.2 create-next-app 플래그 오류

- 파일: `.claude/settings.local.json`
- 문제: `--no-turbo` 플래그가 Next.js 16에서 존재하지 않음
- 영향: 셋업 스크립트 실행 시 에러 발생 가능
- 수정: 해당 플래그 제거

### 3.3 권한 설정 과도하게 넓음

- 파일: `.claude/settings.local.json`
- 문제: `Bash(git:*)`, `Bash(claude:*)` 등이 모든 하위 명령 허용
- 영향: force push, branch -D 같은 위험한 명령도 무조건 허용
- 수정: 패턴을 구체적으로 제한 (예: `git push`만 허용, `--force` 제외)

### 3.4 hooks 패턴 범위 과다

- 파일: `hooks/hooks.json`
- 문제: `Write|Edit` 패턴이 모든 파일 쓰기에 트리거
- 영향: TypeScript/Prisma와 무관한 파일에도 불필요한 검증 실행
- 수정: `src/**/*.{ts,tsx}`, `prisma/schema.prisma`로 패턴 제한

---

## 4. 개선 필요 사항

### 4.1 스킬 기술적 보완

| 스킬 | 항목 | 상세 |
|------|------|------|
| better-auth | 2FA/MFA 패턴 추가 | v1.4+ 지원하는 TOTP, SMS 인증 가이드 |
| better-auth | 소셜 로그인 통합 | Google, GitHub, Kakao OAuth 연동 패턴 |
| better-auth | 세션 갱신 엣지케이스 | 만료 직전 갱신, 다중 디바이스 처리 |
| prisma-7 | 소프트 딜리트 전략 | `deletedAt` 필드 + 쿼리 필터링 + 인덱스 전략 |
| prisma-7 | 마이그레이션 충돌 해결 | 다수 개발자 동시 작업 시 충돌 패턴 |
| prisma-7 | 폴리모픽 관계 | 다형성 테이블 설계 가이드 |
| prisma-7 | 커넥션 풀 에러 처리 | Pool exhaustion 시 fallback 전략 |
| coding-conventions | API Route 패턴 | REST 엔드포인트 설계, 응답 표준화 |
| coding-conventions | 에러 핸들링 | Error Boundary, try-catch 패턴 체계화 |

### 4.2 커맨드 보완

| 커맨드 | 항목 | 상세 |
|--------|------|------|
| code-review | 접근성(a11y) 검증 추가 | WCAG 2.1 AA 기준 체크리스트 |
| task | 브랜치 충돌 처리 | 이미 존재하는 브랜치명과의 충돌 핸들링 |
| task | dev 브랜치 미존재 대응 | main만 있는 프로젝트에서의 fallback |
| commit | 스코프 확장 | "schema", "deps", "config" 등 추가 |
| commit | breaking change 가이드 | `!` 접미사 및 BREAKING CHANGE footer |
| pr | 템플릿 보강 | 배포 지침, 롤백 계획, 성능 영향 섹션 |
| schema-design | 소프트 딜리트 인덱스 | 삭제된 레코드 제외 인덱스 패턴 |
| design-feature | 캐싱 전략 | ISR vs Dynamic vs PPR 결정 트리 |

### 4.3 누락된 커맨드 (신규 추가 제안)

| 커맨드 | 용도 | 우선순위 |
|--------|------|----------|
| `/enf:health` | 플러그인 설치 상태 및 프로젝트 검증 | 높음 (TODO.md에도 이미 있음) |
| `/enf:security-audit` | OWASP 기반 보안 취약점 점검 | 높음 |
| `/enf:test` | 테스트 작성 가이드 및 실행 | 높음 (사용자 요청) |
| `/enf:dependency-audit` | 의존성 버전/취약점 검사 | 중간 |
| `/enf:bundle-analyze` | 번들 사이즈 분석 및 핫스팟 탐지 | 중간 |

---

## 5. 실사용 시나리오 검증

### 5.1 워크플로우 효과성

```
/enf:task → /enf:design-feature → [구현] → /enf:code-review → /enf:commit → /enf:push → /enf:pr
```

이 흐름은 실전에서 잘 작동할 구조이며, 각 커맨드가 독립적으로 호출되므로 필요에 따라 건너뛸 수 있는 유연성이 있다.

### 5.2 엣지케이스

| 시나리오 | 현재 대응 | 개선 필요 |
|---------|----------|----------|
| 브랜치명 충돌 (`feat/login` 이미 존재) | 미처리 | 존재 여부 확인 후 suffix 추가 또는 안내 |
| dev 브랜치 없는 프로젝트 | 미처리 | main 기반 fallback 로직 |
| 모노레포 환경 (pnpm workspace) | 미지원 | 워크스페이스 루트 감지 및 패키지 선택 |
| .env.local 실수로 커밋 | 미방어 | commit 시 .gitignore 체크 추가 |
| MCP 서버 미응답 (context7 다운 등) | 타임아웃 설정 없음 | 그레이스풀 폴백 안내 |
| 1000줄+ 대형 파일 리뷰 | 미고려 | 청크 단위 분석 가이드 |

### 5.3 커맨드 독립성 평가

각 커맨드가 `/enf:` 네임스페이스로 분리되어 독립 호출되는 구조는 적절하다. `/waterfall-check`과 `/perf-audit`의 워터폴 분석 중복도 "빠른 단일 체크" vs "전체 성능 감사"로 사용 목적이 다르므로 현 구조 유지가 합리적이다.

---

## 6. 경쟁력 및 차별화 분석

### 6.1 강점

- **한국어 네이티브**: Claude Code 플러그인 중 한국어 전용은 거의 없음. 한국 개발자 시장에서 독보적 포지션
- **실전 노하우 체계화**: Co-location 원칙, Server Action 패턴, 워터폴 방지 등 바이브 코딩에서 검증된 패턴들이 구조화됨
- **워크플로우 완결성**: task → design → 구현 → review → commit → push → pr 전체 사이클 커버
- **기술 스택 집중**: Next.js 16 + Prisma 7 + Better Auth 조합에 특화되어 깊이 있는 가이드 제공
- **에이전트-커맨드 분리**: 설계(architecture-expert)와 구현(dev-assistant)이 명확히 분리됨

### 6.2 약점 및 리스크

- **영어 미지원**: 모든 문서/스킬/커맨드가 한국어 전용 → 글로벌 마켓플레이스 노출 제한
- **테스트 영역 공백**: Unit/Integration/E2E 테스트 패턴이 전무 → "풀스택"이라 하기엔 개발 후반부가 약함
- **배포/모니터링 부재**: Vercel 배포, Sentry 에러 추적, 분석 통합 등 프로덕션 레벨 가이드 없음
- **모노레포 미지원**: 단일 앱 구조만 가정 → 실무에서 모노레포 쓰는 팀에 적용 불가
- **커스터마이징 제한**: 스킬/커맨드 override나 확장 메커니즘 없음 → 팀별 커스텀 어려움
- **MCP 서버 의존성**: context7, next-devtools 등 외부 서비스 다운 시 그레이스풀 폴백 없음

### 6.3 시장 포지셔닝

```
                    기술 스택 특화도
                         ↑
                         │
           ENF Plugin ●  │
          (Next.js 전문)  │
                         │
    범용 플러그인 ●───────┼───────● 엔터프라이즈 솔루션
  (다양한 스택 지원)       │       (CI/CD, 테스트, 배포 통합)
                         │
                         │
                         └──────────→ 개발 라이프사이클 커버리지
```

현재 "기술 스택 특화"는 강하지만, "라이프사이클 커버리지"가 부족.
테스트, 배포, 모니터링 추가 시 우상단(전문 + 완결)으로 이동 가능.

---

## 7. 사용자(lemon-etvibe) 요청 사항

리뷰 논의 과정에서 도출된 추가 작업 의지 항목:

### 7.1 영문 버전 (i18n)

- 현재: 전체 한국어
- 목표: 스킬/커맨드/에이전트/문서 이중 언어 지원
- 접근법 검토 필요:
  - (A) 별도 영문 파일 (`SKILL.en.md`) — 유지보수 부담 큼
  - (B) 단일 파일 내 이중 언어 섹션 — 가독성 저하
  - (C) 영문 전용 브랜치 또는 릴리즈 — 관리 복잡
  - (D) 핵심 문서만 영문화 (README, SKILL 4개) — 현실적 타협안

### 7.2 모노레포화

- 현재: 단일 앱 구조 가정
- 목표: pnpm workspace 기반 멀티 패키지 지원
- 고려 사항:
  - 플러그인 자체를 모노레포로 구조화할 것인지
  - 모노레포 프로젝트를 지원하는 스킬/커맨드를 추가할 것인지
  - 또는 둘 다인지

### 7.3 테스트 패턴 스킬 추가

- 현재: 테스트 관련 가이드 전무
- 목표: 테스트 스킬 및 커맨드 신규 생성
- 포함 항목 (예상):
  - Vitest 기반 Unit Test 패턴
  - Testing Library 기반 컴포넌트 테스트
  - Playwright 기반 E2E 테스트
  - Server Action 테스트 패턴
  - MSW(Mock Service Worker) 활용 API 모킹
  - `/enf:test` 커맨드 — 테스트 작성 가이드 및 실행

---

## 8. 개선 로드맵 제안

### Phase 1: 크리티컬 수정 (1-2시간)

- [ ] Better Auth proxy.ts 패턴 → API Route handler 패턴으로 업데이트
- [ ] settings.local.json에서 `--no-turbo` 플래그 제거
- [ ] hooks.json 패턴을 TypeScript/Prisma 파일로 제한
- [ ] 권한 설정 범위 축소

### Phase 2: 스킬 보강 (1-2일)

- [ ] better-auth 스킬: 2FA/MFA, 소셜 로그인 추가
- [ ] prisma-7 스킬: 소프트 딜리트, 마이그레이션 충돌 해결 추가
- [ ] coding-conventions 스킬: API Route 패턴, 에러 핸들링 추가
- [ ] 각 커맨드 엣지케이스 보완 (브랜치 충돌, .env 방어 등)

### Phase 3: 신규 기능 (3-5일)

- [ ] 테스트 패턴 스킬 신규 생성 (`skills/testing/SKILL.md`)
- [ ] `/enf:test` 커맨드 추가
- [ ] `/enf:health` 커맨드 추가
- [ ] `/enf:security-audit` 커맨드 추가

### Phase 4: 확장 (1-2주)

- [ ] 영문 버전 핵심 문서 번역 (README, SKILL 4개, COMMANDS-REFERENCE)
- [ ] 모노레포 지원 스킬 또는 가이드 추가
- [ ] 배포/모니터링 가이드 추가

---

## 9. 기술 정확성 상세

### Next.js 16 관련

| 항목 | 정확도 | 비고 |
|------|--------|------|
| App Router 패턴 | 9/10 | layouts, route groups 올바름 |
| Server Components | 9/10 | async 패턴 정확 |
| Server Actions | 9/10 | useActionState 사용 현대적 |
| Middleware (proxy.ts) | 6/10 | deprecated 패턴, API Route로 전환 필요 |
| Dynamic imports | 9/10 | ssr: false 사용 올바름 |
| Image 최적화 | 8/10 | priority, sizes 적절 |

### Prisma 7 관련

| 항목 | 정확도 | 비고 |
|------|--------|------|
| pg adapter 설정 | 9/10 | Pool 구성 올바름 |
| prisma.config.ts | 10/10 | Prisma 7 요구사항 충족 |
| Query 최적화 | 9/10 | select/include 패턴 정확 |
| Relations | 9/10 | 1:N, N:M 패턴 정확 |
| Migrations | 8/10 | preview feature migration 미언급 |

### Better Auth 1.4.x 관련

| 항목 | 정확도 | 비고 |
|------|--------|------|
| 세션 설정 | 9/10 | config 올바름 |
| Auth client | 9/10 | useSession 현대적 |
| 서버 인증 | 9/10 | auth.api.getSession() 정확 |
| 미들웨어 proxy | 5/10 | **구식** — v1.4에서 미권장 |

### Tailwind v4 관련

| 항목 | 정확도 | 비고 |
|------|--------|------|
| @theme 디렉티브 | 9/10 | CSS-first 설정 정확 |
| Lightning CSS | 9/10 | PostCSS 정보 정확 |
| JIT 모드 | 8/10 | 기본 활성, 플러그인용 config 필요 가능 |

---

## 부록: TODO.md 현황과의 대조

현재 TODO.md에 있는 항목들과 본 리뷰의 제안이 상당 부분 겹침:

| TODO.md 항목 | 본 리뷰 제안 | 상태 |
|-------------|-------------|------|
| 프로젝트 헬스체크 커맨드 | `/enf:health` 커맨드 추가 | 일치 |
| 의존성 버전 검사 | `/enf:dependency-audit` 커맨드 | 일치 |
| 환경 변수 템플릿 생성 | commit 시 .env 방어 체크 | 관련 |
| 영문 README | 영문 버전 전체 확장 | 확장 |
| 새 프로젝트 생성 스크립트 | (본 리뷰 범위 외) | — |

---

*이 리포트는 플러그인 개선 작업의 기준 문서로 활용됩니다.*
*다음 단계: Phase 1 크리티컬 수정부터 순차 진행*
