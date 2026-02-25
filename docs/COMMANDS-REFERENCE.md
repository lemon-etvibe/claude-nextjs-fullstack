# 커맨드 레퍼런스

플러그인에서 사용 가능한 모든 커맨드의 빠른 참조 가이드입니다.

---

## 목차

- [ENF 커맨드 빠른 참조](#enf-커맨드-빠른-참조)
- [외부 플러그인 커맨드](#외부-플러그인-커맨드)
- [언제 무엇을 쓸까?](#언제-무엇을-쓸까)
- [커맨드 상세](#커맨드-상세)

---

## ENF 커맨드 빠른 참조

모든 ENF 커맨드는 `/enf:` 접두사를 사용합니다.

| 커맨드 | 용도 | 인자 |
|--------|------|------|
| `/enf:init` | 플러그인 가이드 확인 | - |
| `/enf:task` | 작업 브랜치 생성 | `"작업명"` |
| `/enf:code-review` | 코드 품질 검사 | `[파일경로]` |
| `/enf:commit` | Conventional Commit 생성 | - |
| `/enf:push` | 안전 체크 후 푸시 | `[--force]` `[-u]` |
| `/enf:pr` | GitHub PR 생성 | `[--draft]` `[--release]` `[--version]` |
| `/enf:design-feature` | 아키텍처 설계 | `"기능 설명"` |
| `/enf:schema-design` | Prisma 스키마 리뷰 | - |
| `/enf:perf-audit` | 성능 분석 | - |
| `/enf:refactor` | 리팩토링 제안 | `<파일경로>` |
| `/enf:type-check` | TypeScript 검증 | - |
| `/enf:waterfall-check` | 순차 await 검출 | `[경로]` |
| `/enf:test` | 테스트 실행/생성 | `[파일경로]` `[--e2e]` `[--coverage]` `[--setup]` |
| `/enf:generate-docs` | API 문서 생성 | - |
| `/enf:component-docs` | 컴포넌트 문서 생성 | - |
| `/enf:update-changelog` | CHANGELOG 업데이트 | - |
| `/enf:health` | 버전 호환성 검사 | - |

### 분류별 정리

#### Git 워크플로우

```bash
/enf:task "로그인 기능 구현"   # 브랜치 생성: feat/login-feature
/enf:commit                     # 변경사항 커밋
/enf:push -u                    # 첫 푸시 (upstream 설정)
/enf:push                       # 이후 푸시
/enf:pr                         # PR 생성 (→ dev)
/enf:pr --draft                 # Draft PR 생성
/enf:pr --release               # 릴리스 PR (dev → main)
```

#### 코드 품질

```bash
/enf:code-review                     # 전체 변경사항 리뷰
/enf:code-review src/app/page.tsx    # 특정 파일 리뷰
/enf:type-check                      # TypeScript strict 검증
/enf:refactor src/lib/utils.ts       # 리팩토링 제안
```

#### 설계 & 성능

```bash
/enf:design-feature "결제 시스템"    # 아키텍처 설계
/enf:schema-design                   # Prisma 스키마 리뷰
/enf:perf-audit                      # 번들/성능 분석
/enf:waterfall-check                 # 전체 프로젝트 검사
/enf:waterfall-check src/app/        # 특정 디렉토리 검사
```

#### 테스트

```bash
/enf:test                                    # 전체 테스트 실행
/enf:test src/app/(admin)/_actions/customer.ts  # 테스트 생성
/enf:test --e2e                              # E2E 테스트 실행
/enf:test --coverage                         # 커버리지 포함
/enf:test --setup                            # 초기 설정
```

#### 진단

```bash
/enf:health              # 프로젝트 버전 호환성 검사
```

#### 문서화

```bash
/enf:generate-docs      # Server Action/API 문서
/enf:component-docs     # React 컴포넌트 Props 문서
/enf:update-changelog   # CHANGELOG 자동 업데이트
```

---

## 외부 플러그인 커맨드

셋업 스크립트가 설치하는 외부 플러그인입니다.

### 빠른 참조

| 플러그인 | 호출 방식 | 용도 |
|----------|----------|------|
| **commit-commands** | `/commit` | 변경사항 분석 후 커밋 생성 |
| **pr-review-toolkit** | `/review-pr` | 6가지 관점 PR 리뷰 |
| **feature-dev** | `/feature-dev` | 기능 개발 워크플로우 |
| **code-review** | `/code-review` | 자동 코드 리뷰 |
| **playwright** | 자동 | E2E 테스트 작성/실행 |
| **context7** | 자동 (MCP) | 라이브러리 문서 조회 |
| **security-guidance** | 자동 | OWASP Top 10 보안 검사 |
| **frontend-design** | 자동 (스킬) | 고품질 UI 디자인 생성 |

---

### `/commit` (commit-commands)

변경사항을 분석하여 커밋 메시지를 생성합니다.

```bash
/commit              # 변경사항 분석 → 커밋 메시지 생성 → 커밋
```

**ENF `/enf:commit`과 차이점**:
- `/commit`: 자유 형식 커밋 메시지
- `/enf:commit`: Conventional Commits 형식 강제

---

### `/review-pr` (pr-review-toolkit)

PR을 6가지 관점에서 상세 리뷰합니다.

```bash
/review-pr           # 현재 브랜치의 PR 리뷰
/review-pr 123       # PR #123 리뷰
```

**6가지 리뷰 관점**:
| 관점 | 검사 내용 |
|------|----------|
| 코드 품질 | 가독성, 중복, 복잡도 |
| 보안 취약점 | 인젝션, XSS, 인증 우회 |
| 성능 이슈 | N+1, 메모리 누수, 불필요한 연산 |
| 테스트 커버리지 | 테스트 누락, 엣지 케이스 |
| 타입 안전성 | any 사용, 타입 누락 |
| 코멘트 정확성 | 코멘트-코드 불일치 |

---

### `/feature-dev` (feature-dev)

기능 개발을 단계별로 가이드합니다.

```bash
/feature-dev         # 기능 개발 워크플로우 시작
```

**워크플로우**:
1. 코드베이스 분석 (기존 패턴 파악)
2. 아키텍처 설계 (구조 제안)
3. 구현 가이드 (단계별 구현)

**ENF `/enf:design-feature`와 차이점**:
- `/feature-dev`: 분석 → 설계 → 구현까지 전체 가이드
- `/enf:design-feature`: 설계만 담당 (구현은 dev-assistant)

---

### `/code-review` (code-review)

코드를 자동으로 리뷰하고 개선점을 제안합니다.

```bash
/code-review                     # 전체 변경사항 리뷰
/code-review src/app/page.tsx    # 특정 파일 리뷰
```

**ENF `/enf:code-review`와 차이점**:
- `/code-review`: 범용 코드 리뷰
- `/enf:code-review`: Next.js + Prisma + Better Auth 특화 리뷰

---

### frontend-design (스킬)

고품질 프론트엔드 UI를 디자인합니다. UI 관련 작업 요청 시 자동 활성화됩니다.

```bash
# 자동 활성화 예시
> 로그인 페이지를 만들어줘
> 대시보드 UI를 디자인해줘
> 랜딩 페이지 컴포넌트를 작성해줘
```

**특징**:
- 모던 디자인 패턴 적용
- 반응형 레이아웃
- 접근성(a11y) 고려
- Tailwind CSS 코드 생성

---

### playwright

E2E 테스트를 작성하고 실행합니다.

```bash
# 테스트 작성 요청
> 로그인 플로우 E2E 테스트를 작성해줘

# 테스트 실행
> playwright 테스트를 실행해줘
```

**특징**:
- 브라우저 자동화 테스트
- 스크린샷/비디오 캡처
- 크로스 브라우저 테스트

---

### context7 (MCP)

라이브러리 공식 문서를 실시간으로 조회합니다.

```bash
# 자동 활성화 (MCP 서버)
> Next.js 16의 새로운 기능이 뭐야?
> Prisma 7 마이그레이션 방법 알려줘
```

**특징**:
- 최신 문서 실시간 조회
- 버전별 문서 지원
- 코드 예시 포함

---

### security-guidance

OWASP Top 10 기반 보안 취약점을 검사합니다.

```bash
# 보안 검사 요청
> 이 코드의 보안 취약점을 검사해줘
> SQL 인젝션 위험이 있는지 확인해줘
```

**검사 항목**:
| 취약점 | 검사 내용 |
|--------|----------|
| Injection | SQL, NoSQL, OS 명령어 인젝션 |
| XSS | 크로스 사이트 스크립팅 |
| CSRF | 크로스 사이트 요청 위조 |
| Auth | 인증/인가 우회 |
| Secrets | 하드코딩된 비밀키 |

---

### 커뮤니티 에이전트 (wshobson/agents)

| 에이전트 | 플러그인 | 용도 |
|----------|----------|------|
| `javascript-pro` | javascript-typescript | JS 최적화, async 패턴 |
| `typescript-pro` | javascript-typescript | 고급 타입, 제네릭 |
| `sql-pro` | database-design | SQL 최적화, 쿼리 튜닝 |
| `database-architect` | database-design | 스키마 설계 |

> 에이전트는 Task tool로 자동 호출됩니다. 직접 슬래시 커맨드가 아닙니다.

```bash
# 사용 예시
> TypeScript 제네릭 패턴을 최적화해줘
# → typescript-pro 에이전트 자동 활성화

> PostgreSQL 쿼리를 최적화해줘
# → sql-pro 에이전트 자동 활성화
```

---

## 언제 무엇을 쓸까?

### 시나리오별 커맨드 선택

```
[작업 시작]
└─ /enf:task "작업명"

[설계가 필요한 기능]
└─ /enf:design-feature "기능 설명"

[코드 작성 완료]
├─ /enf:code-review        ← 자체 리뷰
└─ /enf:type-check         ← 타입 검증

[커밋 & 푸시]
├─ /enf:commit             ← Conventional Commits 형식
└─ /commit                 ← 자유 형식 (외부 플러그인)

[PR 생성]
└─ /enf:pr

[PR 리뷰 요청]
└─ /review-pr              ← 6가지 관점 상세 리뷰
```

### ENF vs 외부 플러그인

| 상황 | ENF 커맨드 | 외부 플러그인 |
|------|-----------|---------------|
| 커밋 생성 | `/enf:commit` (Conventional) | `/commit` (자유 형식) |
| 코드 리뷰 | `/enf:code-review` (빠른 검사) | `/review-pr` (상세 분석) |
| 기능 설계 | `/enf:design-feature` | `/feature-dev` |

### 추천 워크플로우

```bash
# 1. 작업 시작
/enf:task "사용자 프로필 페이지"

# 2. 설계 (복잡한 기능)
/enf:design-feature "사용자 프로필 조회/수정 기능"

# 3. 구현 (Claude에게 요청)
> 프로필 페이지를 구현해줘

# 4. 리뷰
/enf:code-review

# 5. 커밋 & 푸시
/enf:commit
/enf:push

# 6. PR 생성
/enf:pr
```

---

## 커맨드 상세

### `/enf:task`

작업 브랜치를 생성합니다.

```bash
/enf:task "로그인 기능 구현"
# → feat/login-feature 브랜치 생성 (dev에서 분기)

/enf:task "버튼 색상 버그"
# → fix/button-color-bug 브랜치 생성
```

**브랜치 네이밍 규칙**:
- `feat/*` - 새 기능
- `fix/*` - 버그 수정
- `refactor/*` - 리팩토링
- `docs/*` - 문서
- `chore/*` - 기타 작업

### `/enf:code-review`

TypeScript, 성능, 보안 관점의 코드 품질 검사입니다.

```bash
/enf:code-review                          # 변경된 파일 전체
/enf:code-review src/app/(admin)/         # 특정 디렉토리
/enf:code-review src/lib/auth.ts          # 특정 파일
```

**검사 항목**:
- TypeScript strict 준수
- `any` 타입 사용 여부
- Better Auth 인증 패턴
- 순차 await (waterfall) 패턴
- Import 순서 규칙

### `/enf:commit`

Conventional Commits 형식의 커밋을 생성합니다.

```bash
/enf:commit
# → feat(auth): 로그인 기능 구현
# → fix(ui): 버튼 색상 수정
```

**커밋 타입**:
- `feat` - 새 기능
- `fix` - 버그 수정
- `refactor` - 리팩토링
- `docs` - 문서
- `style` - 포맷팅
- `test` - 테스트
- `chore` - 기타

### `/enf:push`

안전 체크 후 원격 저장소에 푸시합니다.

```bash
/enf:push           # 현재 브랜치 푸시
/enf:push -u        # upstream 설정 후 푸시 (첫 푸시)
/enf:push --force   # 강제 푸시 (주의!)
```

**안전 체크**:
- 현재 브랜치가 main/dev가 아닌지 확인 (보호 브랜치)
- 커밋되지 않은 변경사항 확인
- 원격 브랜치와 충돌 여부 확인

**--force 경고**: 개인 브랜치의 rebase 후에만 사용

### `/enf:pr`

GitHub PR을 생성합니다.

```bash
/enf:pr                         # feat/* → dev PR 생성
/enf:pr --draft                 # Draft PR 생성
/enf:pr --release               # dev → main 릴리스 PR
/enf:pr --release --version 1.2.0  # 버전 지정 릴리스 PR
/enf:pr --base main             # 타겟 브랜치 수동 지정
```

**PR 템플릿 자동 적용**:
- 제목: 브랜치명 기반 (Conventional Commits)
- 본문: 커밋 내역 요약
- 라벨: 브랜치 타입별 자동 지정

### `/enf:design-feature`

새 기능의 아키텍처를 설계합니다.

```bash
/enf:design-feature "결제 시스템 구현"
```

**설계 항목**:
- Route Group 결정
- 데이터 모델 (Prisma 스키마)
- API 패턴 (Server Action vs API Route)
- 컴포넌트 구조
- 인증/권한 처리

### `/enf:schema-design`

Prisma 스키마를 리뷰합니다.

```bash
/enf:schema-design
```

**리뷰 항목**:
- 관계 설정 적절성
- 인덱스 최적화
- 타입 선택 (String vs Enum)
- 마이그레이션 안전성

### `/enf:perf-audit`

번들 크기 및 성능을 분석합니다.

```bash
/enf:perf-audit
```

**분석 항목**:
- 번들 크기 분석
- 불필요한 'use client' 검출
- dynamic import 제안
- Core Web Vitals 영향 분석

### `/enf:health`

프로젝트의 버전 호환성을 검증합니다.

```bash
/enf:health              # 전체 호환성 검사
```

**검사 항목**:
- package.json 의존성 버전 (Next.js, React, Prisma, Better Auth, Tailwind, TypeScript)
- MCP 서버 버전 (.mcp.json)
- 스킬별 tested-with 메타데이터 호환성

**판정 기준**:
| 상태 | 의미 |
|------|------|
| ✅ PASS | 지원 범위 내 |
| ⚠️ WARN | 미설치 또는 파싱 불가 |
| ❌ FAIL | 메이저 버전 불일치 |

**참고**: [COMPATIBILITY.md](./COMPATIBILITY.md) — 지원 버전 매트릭스 상세

### `/enf:test`

테스트를 실행하거나 테스트 코드를 생성합니다.

```bash
/enf:test                     # 전체 테스트 실행
/enf:test <파일경로>          # 해당 파일의 테스트 생성
/enf:test --e2e               # Playwright E2E 실행
/enf:test --coverage          # 커버리지 리포트
/enf:test --setup             # 테스트 환경 초기 설정
```

**테스트 유형**:
- 단위 테스트 (Vitest) — Server Action, 유틸, Zod 스키마
- 컴포넌트 테스트 (Testing Library) — React 클라이언트 컴포넌트
- E2E 테스트 (Playwright) — 전체 사용자 플로우

**파일 분류**: 경로 패턴 우선 (`_actions/` → Server Action), 불명확 시 파일 내용 분석

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [GUIDELINES](./GUIDELINES.md) | 워크플로우 원칙 |
| [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 상세 사용법 |
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 상황별 가이드 |
