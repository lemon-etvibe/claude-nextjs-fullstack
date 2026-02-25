# 시나리오별 가이드

etvibe-nextjs-fullstack (enf) 플러그인을 사용한 상황별 워크플로우 가이드입니다.

---

## 목차

- [일상 개발](#일상-개발)
- [문제 해결](#문제-해결)
- [고급 시나리오](#고급-시나리오)
- [FAQ](#faq)

---

## 일상 개발

### 1. 새 기능 개발

#### 시나리오
"고객 검색 기능을 추가해야 해요"

#### 워크플로우

```bash
# 1. 작업 시작 - 브랜치 생성
> /enf:task "고객 검색 기능"
# → feat/customer-search 브랜치 생성

# 2. (선택) 복잡한 기능이면 설계 먼저
> /enf:design-feature "고객 검색 필터 및 정렬 기능"

# 3. 구현 요청
> 고객 목록 페이지에 검색 기능을 추가해줘
# 검색 조건: 이름, 이메일, 상태

# 4. 코드 리뷰
> /enf:code-review src/app/(admin)/_components/CustomerSearchForm.tsx

# 5. 커밋
> /enf:commit

# 6. 푸시 및 PR
> /enf:push
> /enf:pr
```

#### 예상 결과
- 검색 폼 컴포넌트 생성
- URL 기반 검색 파라미터 처리
- 서버 사이드 필터링 적용

---

### 2. 리팩토링

#### 시나리오
"CustomerTable 컴포넌트가 너무 복잡해졌어요"

#### 워크플로우

```bash
# 1. 리팩토링 분석 요청
> /enf:refactor src/app/(admin)/_components/CustomerTable.tsx

# 2. 제안 검토 후 적용
> 제안대로 리팩토링해줘

# 3. 타입 검증
> /enf:type-check src/app/(admin)/_components/

# 4. 코드 리뷰
> /enf:code-review src/app/(admin)/_components/

# 5. 커밋
> /enf:commit
```

#### 리팩토링 패턴
- 컴포넌트 분리 (단일 책임)
- 커스텀 훅 추출
- 타입 정의 분리
- 매직 넘버 상수화

---

### 3. Prisma 스키마 변경

#### 시나리오
"캠페인에 예산 필드를 추가해야 해요"

#### 워크플로우

```bash
# 1. 스키마 설계 리뷰
> /enf:schema-design
# 현재 Campaign 모델에 budget 필드 추가 계획 설명

# 2. 스키마 수정 요청
> prisma/schema.prisma에 Campaign 모델에 budget 필드를 추가해줘
# 타입: Decimal, 기본값: 0

# 3. 마이그레이션
> pnpm prisma migrate dev --name add_campaign_budget

# 4. 관련 코드 업데이트
> 캠페인 생성/수정 폼에 budget 필드를 추가해줘

# 5. 커밋
> /enf:commit
```

#### 주의사항
- `onDelete: Cascade` 사용 시 연쇄 삭제 주의
- 인덱스 필요 여부 검토
- 기존 데이터 마이그레이션 계획

---

### 4. PR 생성

#### 시나리오
"기능 개발이 완료되어 PR을 생성하고 싶어요"

#### 워크플로우

```bash
# 1. 변경사항 확인
> git status

# 2. 최종 코드 리뷰
> /enf:code-review

# 3. 커밋 (아직 안 했다면)
> /enf:commit

# 4. 푸시
> /enf:push

# 5. PR 생성
> /enf:pr
```

#### PR 템플릿 자동 생성
```markdown
## 변경 내용
- 고객 검색 기능 추가
- 검색 필터 컴포넌트 구현

## 테스트
- [ ] 이름 검색 동작 확인
- [ ] 이메일 검색 동작 확인
- [ ] 빈 결과 처리 확인

## 스크린샷
(필요시 첨부)
```

---

### 5. 테스트 작성

#### 시나리오
"고객 관리 기능에 테스트를 추가해야 해요"

#### 워크플로우

```bash
# 1. (최초 1회) 테스트 환경 설정
> /enf:test --setup

# 2. Server Action 테스트 생성
> /enf:test src/app/(admin)/_actions/customer.ts

# 3. 컴포넌트 테스트 생성
> /enf:test src/app/(admin)/_components/CustomerTable.tsx

# 4. 테스트 실행
> /enf:test

# 5. 커버리지 확인
> /enf:test --coverage

# 6. 커밋
> /enf:commit
```

#### 테스트 유형별 선택 기준

| 대상 | 테스트 유형 | 도구 |
|------|-----------|------|
| Server Action 로직 | 단위 테스트 | Vitest |
| Zod 스키마 검증 | 단위 테스트 | Vitest |
| React 클라이언트 컴포넌트 | 컴포넌트 테스트 | Testing Library |
| 전체 사용자 플로우 (로그인 등) | E2E 테스트 | Playwright |

---

## 문제 해결

### 1. 페이지가 느려요

#### 시나리오
"고객 상세 페이지 로딩이 너무 느려요"

#### 워크플로우

```bash
# 1. 성능 분석
> /enf:perf-audit src/app/(admin)/admin/(protected)/customers/[id]/

# 2. Waterfall 패턴 확인
> /enf:waterfall-check src/app/(admin)/admin/(protected)/customers/[id]/

# 3. 분석 결과 확인 후 최적화 요청
> 발견된 성능 문제를 수정해줘

# 4. 코드 리뷰
> /enf:code-review

# 5. 커밋
> /enf:commit
```

#### 흔한 원인

| 원인 | 해결책 |
|------|--------|
| 순차 await | Promise.all로 병렬화 |
| N+1 쿼리 | Prisma include 사용 |
| 큰 번들 | dynamic import |
| 불필요한 데이터 | select로 필요 필드만 |

---

### 2. TypeScript 에러

#### 시나리오
"타입 에러가 발생하는데 어떻게 수정해야 할지 모르겠어요"

#### 워크플로우

```bash
# 1. 타입 검사
> /enf:type-check src/

# 2. 에러 내용 공유
> 이 타입 에러를 해결해줘
# (에러 메시지 붙여넣기)

# 3. 수정 확인
> pnpm tsc --noEmit

# 4. 커밋
> /enf:commit
```

#### 흔한 타입 에러

```typescript
// 문제: any 타입 사용
const data: any = fetchData() // ❌

// 해결: 구체적 타입 또는 unknown
const data: Customer = fetchData() // ✅
const data: unknown = fetchData() // ✅

// 문제: nullable 처리 누락
const name = user.name.toUpperCase() // ❌

// 해결: optional chaining
const name = user?.name?.toUpperCase() // ✅
```

---

### 3. 인증 문제

#### 시나리오
"Server Action에서 세션이 없다고 나와요"

#### 워크플로우

```bash
# 1. 인증 패턴 확인
> 이 Server Action의 인증 코드를 확인해줘

# 2. Better Auth 스킬 활성화된 상태로 수정
> Better Auth 패턴으로 인증 코드를 수정해줘

# 3. 코드 리뷰
> /enf:code-review
```

#### 올바른 패턴

```typescript
// Server Action
"use server"

import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export async function updateCustomer(...) {
  // 반드시 await headers() 사용
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: "로그인이 필요합니다." }
  }

  // 권한 체크
  if (session.user.type !== "admin") {
    return { error: "권한이 없습니다." }
  }

  // 비즈니스 로직...
}
```

---

## 고급 시나리오

### 1. 복잡한 기능 설계

#### 시나리오
"캠페인-인플루언서 매칭 시스템을 설계해야 해요"

#### 워크플로우

```bash
# 1. 설계 요청 (architecture-expert)
> /enf:design-feature "캠페인-인플루언서 매칭 시스템"
# 요구사항:
# - 캠페인에 여러 인플루언서 지원
# - 상태 관리 (지원 → 매칭 → 진행 → 완료)
# - 각 단계별 알림

# 2. 설계 검토 후 데이터 모델 구체화
> /enf:schema-design
# CampaignInfluencer 중간 테이블 필요

# 3. 구현 (dev-assistant)
> 위 설계대로 구현해줘. 먼저 Prisma 스키마부터.

# 4. 성능 검토 (performance-expert)
> /enf:perf-audit

# 5. 문서화 (docs-writer)
> 캠페인-인플루언서 매칭 시스템 문서를 작성해줘
```

---

### 2. 성능 최적화 프로젝트

#### 시나리오
"전체 애플리케이션 성능을 개선해야 해요"

#### 워크플로우

```bash
# 1. 전체 번들 분석
> 번들 크기를 분석해줘
# pnpm build 후 @next/bundle-analyzer

# 2. 주요 페이지 성능 분석
> /enf:perf-audit src/app/(site)/(main)/page.tsx
> /enf:perf-audit src/app/(admin)/admin/(protected)/dashboard/

# 3. Waterfall 패턴 전수 검사
> /enf:waterfall-check src/app/

# 4. 최적화 적용
> 발견된 문제들을 우선순위대로 수정해줘

# 5. 렌더링 전략 검토
> 각 페이지의 렌더링 전략을 검토해줘
# SSG, ISR, Dynamic 중 적절한 것 선택
```

#### 렌더링 전략 기준

| 페이지 | 전략 | 이유 |
|--------|------|------|
| 홈 | SSG + PPR | 정적 + 동적 영역 분리 |
| 인플루언서 목록 | ISR (5분) | 주기적 업데이트 |
| 블로그 상세 | SSG | 변경 거의 없음 |
| 관리자 페이지 | Dynamic | 실시간 데이터 |

---

## FAQ

### 명령어 관련

#### Q: `/enf:commit`과 `/commit`의 차이는?

```bash
/enf:commit          # enf 플러그인 커밋 (프로젝트 컨벤션 적용)
/commit              # commit-commands 플러그인 (범용)
/commit-commands:commit  # 위와 동일
```

#### Q: 명령어 목록을 보려면?

```bash
/enf:init  # 플러그인 가이드 및 명령어 목록
```

### Agent 관련

#### Q: 어떤 Agent를 사용해야 할지 모르겠어요

```
설계가 필요하면 → architecture-expert
구현이 필요하면 → dev-assistant
성능 문제면 → performance-expert
문서 작성이면 → docs-writer
```

#### Q: Agent를 명시적으로 호출하려면?

```bash
> @architecture-expert 이 기능을 설계해줘
> @dev-assistant 이 코드를 수정해줘
```

### Skill 관련

#### Q: Skill은 어떻게 활성화되나요?

관련 키워드를 언급하면 자동 활성화:

```bash
# 인증 관련 언급 → better-auth 스킬
> 로그인 기능을 구현해줘

# Prisma 관련 언급 → prisma-7 스킬
> 스키마를 설계해줘

# UI 관련 언급 → tailwind-v4-shadcn 스킬
> shadcn 폼을 만들어줘
```

#### Q: 특정 Skill 내용을 확인하려면?

```bash
# 스킬 파일 직접 확인
> skills/better-auth/SKILL.md 내용을 보여줘
```

### 문제 해결

#### Q: MCP 서버 연결이 안 돼요

```bash
# 1. MCP 상태 확인
/mcp

# 2. 개발 서버 실행 여부 확인 (next-devtools)
pnpm dev

# 3. Claude 재시작
claude
```

#### Q: Hook이 동작하지 않아요

```bash
# 1. 플러그인 검증
claude plugin validate ~/plugins/enf

# 2. 플러그인 재설치
claude plugin install enf@enf-local --scope local
```

> 심층 진단이 필요하면 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md#hooks-문제-해결)를 참조하세요.

#### Q: 코드 리뷰 결과가 너무 엄격해요

코드 리뷰는 팀 표준을 따릅니다. 특정 규칙을 완화하려면:

```bash
> TypeScript any 경고는 무시하고 리뷰해줘
```

하지만 `any` 사용은 권장하지 않습니다.

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [GUIDELINES](./GUIDELINES.md) | 플러그인 철학 |
| [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 상세 |
| [SKILLS-ACTIVATION](./SKILLS-ACTIVATION.md) | 스킬 활성화 |
| [TROUBLESHOOTING](./TROUBLESHOOTING.md) | 심층 문제 해결 |
| [TEAM-ONBOARDING](./TEAM-ONBOARDING.md) | 팀 온보딩 |
