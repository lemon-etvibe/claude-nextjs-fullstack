# 에이전트 매뉴얼

etvibe-nextjs-fullstack (enf) 플러그인의 4개 에이전트 상세 사용법입니다.

---

## 목차

- [개요](#개요)
- [dev-assistant](#dev-assistant)
- [architecture-expert](#architecture-expert)
- [performance-expert](#performance-expert)
- [docs-writer](#docs-writer)
- [협업 패턴](#협업-패턴)

---

## 개요

### 에이전트 비교표

| Agent | 역할 | Write/Edit | MCP 도구 |
|-------|------|:----------:|----------|
| `dev-assistant` | 코드 구현, 리뷰, 리팩토링 | O | context7 |
| `architecture-expert` | 시스템 설계 (구현 안함) | X | context7, next-devtools |
| `performance-expert` | 성능 분석, 번들 최적화 | O | next-devtools |
| `docs-writer` | 문서 작성 | O | context7 |

### 에이전트 호출 방법

```bash
# Claude에서 자동 선택 (컨텍스트 기반)
> 새 기능을 설계해줘
# → architecture-expert 자동 선택

# 명시적 호출
> @architecture-expert 캠페인 관리 기능을 설계해줘
```

---

## dev-assistant

### 역할

- 코드 구현 및 수정
- 코드 리뷰 및 개선 제안
- TypeScript 타입 안전성 검증
- React/Next.js 베스트 프랙티스 적용
- 리팩토링 및 코드 품질 향상

### 사용 도구

| 도구 | 용도 |
|------|------|
| Read | 파일 읽기 |
| Edit | 파일 수정 |
| Grep | 코드 검색 |
| Glob | 파일 패턴 검색 |
| context7 | 라이브러리 문서 조회 |

### 호출 예시

```bash
# 컴포넌트 구현
> CustomerTable 컴포넌트를 구현해줘. TanStack Table 사용.

# 코드 리뷰
> src/app/(admin)/_actions/customer.ts 코드를 리뷰해줘

# 리팩토링
> 이 파일을 더 깔끔하게 리팩토링해줘

# 버그 수정
> 이 에러를 수정해줘: TypeError: Cannot read property 'id' of undefined
```

### 주요 체크 항목

#### 기본 품질

- TypeScript strict 모드 준수
- `any` 타입 금지 (`unknown` 사용)
- 불필요한 'use client' 제거
- Better Auth 인증 검사 적용
- 적절한 에러 처리
- Prisma 쿼리 최적화 (select/include)
- revalidatePath 캐시 무효화

#### 성능 최적화

- 순차 await waterfall 방지 (Promise.all)
- 무거운 컴포넌트 dynamic import
- RSC → CC 최소 데이터 전달
- lucide-react 아이콘 개별 import

### 출력 형식 예시

```typescript
// src/app/(admin)/_actions/customer.ts
"use server"

import { auth } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { revalidatePath } from "next/cache"
import { headers } from "next/headers"

export async function updateCustomer(
  id: string,
  prevState: unknown,
  formData: FormData
) {
  // 1. 인증
  const session = await auth.api.getSession({
    headers: await headers(),
  })
  if (!session || session.user.type !== "admin") {
    return { error: "권한이 없습니다." }
  }

  // 2. 검증 (Zod)
  // 3. DB 작업
  // 4. 캐시 무효화
  revalidatePath("/admin/customers")

  return { success: true }
}
```

---

## architecture-expert

### 역할

- 시스템 설계 (새 기능/페이지 추가)
- 데이터 모델링 (Prisma 스키마 설계)
- 라우팅 설계 (Route Group, 레이아웃)
- 인증/권한 아키텍처 설계
- API 패턴 결정 (Server Actions vs API Routes)

> **중요**: Write/Edit 도구 없음. 설계만 담당하고 구현은 dev-assistant가 수행.

### 사용 도구

| 도구 | 용도 |
|------|------|
| Read | 현재 코드 분석 |
| Glob | 프로젝트 구조 파악 |
| Grep | 패턴 검색 |
| Bash | 명령 실행 |
| context7 | 프레임워크 문서 조회 |
| next-devtools | 라우트/에러 분석 |

### 호출 예시

```bash
# 새 기능 설계
> 캠페인 관리 기능의 전체 구조를 설계해줘

# 데이터 모델링
> 인플루언서-캠페인 관계를 위한 Prisma 스키마를 설계해줘

# 라우팅 설계
> 고객 마이페이지 라우트 구조를 설계해줘

# API 패턴 결정
> 파일 업로드는 Server Action과 API Route 중 뭐가 좋을까?
```

### 주요 체크 항목

#### 새 기능 추가 시

- 어느 Route Group에 속하는가?
- 인증이 필요한가? 어떤 역할인가?
- 어떤 데이터 모델이 필요한가?
- 기존 모델과 어떤 관계인가?
- Server Action vs API Route?
- 컴포넌트 위치는?
- 캐시 전략은? (ISR/SSG/Dynamic)
- Waterfall 발생 가능성?
- Suspense 경계 위치?

### 출력 형식 예시

```markdown
## 캠페인 관리 기능 설계

### 1. Route Group
- 위치: `(admin)/admin/(protected)/campaigns/`
- 인증: Admin 전용

### 2. 데이터 모델

\`\`\`prisma
model Campaign {
  id         String         @id @default(cuid())
  name       String
  status     CampaignStatus @default(RECRUITING)
  customerId String
  customer   Customer       @relation(...)

  @@index([customerId])
  @@map("campaigns")
}
\`\`\`

### 3. 라우팅 구조

\`\`\`
campaigns/
├── page.tsx          # 목록
├── [id]/
│   ├── page.tsx      # 상세
│   └── edit/
│       └── page.tsx  # 수정
└── new/
    └── page.tsx      # 생성
\`\`\`

### 4. Server Actions

- `createCampaign()` - 캠페인 생성
- `updateCampaign()` - 캠페인 수정
- `deleteCampaign()` - 캠페인 삭제

### 5. 다음 단계

dev-assistant에게 위 설계 기반으로 구현 요청
```

---

## performance-expert

### 역할

- 번들 크기 분석 및 최적화
- Core Web Vitals 개선 (LCP, INP, CLS)
- 렌더링 전략 최적화 (SSG/ISR/PPR)
- Waterfall 패턴 검출 및 해결
- 이미지 최적화

### 사용 도구

| 도구 | 용도 |
|------|------|
| Read | 코드 분석 |
| Edit | 최적화 적용 |
| Grep | 패턴 검색 |
| Bash | 빌드/분석 명령 |
| next-devtools | 런타임 분석 |

### 호출 예시

```bash
# 성능 분석
> 이 페이지의 성능을 분석해줘

# Waterfall 검출
> 순차 await 패턴을 찾아서 최적화해줘

# 번들 분석
> 현재 번들 크기를 분석해줘

# Core Web Vitals
> LCP를 개선할 방법을 알려줘
```

### Core Web Vitals 목표

| 지표 | 목표 | 전략 |
|------|------|------|
| LCP | ≤ 2.5초 | SSG + priority 이미지 |
| INP | ≤ 100ms | Server Components |
| CLS | ≤ 0.1 | width/height 명시 |

### 주요 체크 항목

#### LCP (Largest Contentful Paint)

- LCP 요소에 priority 속성
- 크리티컬 CSS 인라인화
- 서버 응답 시간 < 200ms
- 폰트 최적화 (next/font)

#### INP (Interaction to Next Paint)

- 'use client' 최소화
- 이벤트 핸들러 최적화
- useDeferredValue 활용
- React.lazy 동적 임포트

#### CLS (Cumulative Layout Shift)

- 모든 이미지 width/height 명시
- 폰트 display: swap
- 스켈레톤 UI 사용
- 동적 콘텐츠 공간 예약

### 출력 형식 예시

```markdown
## 성능 분석 결과

### 발견된 문제

#### 1. Waterfall 패턴 (심각도: 높음)

위치: `src/app/(admin)/admin/(protected)/customers/[id]/page.tsx:15`

\`\`\`typescript
// ❌ 현재 (순차 실행 - 650ms)
const customer = await fetchCustomer(id)
const campaigns = await fetchCampaigns(id)
const stats = await fetchStats(id)

// ✅ 수정 (병렬 실행 - 250ms)
const [customer, campaigns, stats] = await Promise.all([
  fetchCustomer(id),
  fetchCampaigns(id),
  fetchStats(id),
])
\`\`\`

#### 2. 번들 크기 (심각도: 중간)

- lucide-react 전체 import 발견
- 예상 절감: ~50KB

### 권장 조치

1. Promise.all 적용
2. lucide-react 개별 import
3. 모달 컴포넌트 dynamic import
```

---

## docs-writer

### 역할

- README.md 및 프로젝트 문서 작성
- API 문서 및 타입 문서화
- 컴포넌트 사용 가이드 작성
- 온보딩 문서 및 튜토리얼 작성
- CHANGELOG 관리

### 사용 도구

| 도구 | 용도 |
|------|------|
| Read | 코드/문서 읽기 |
| Write | 문서 생성 |
| Edit | 문서 수정 |
| Glob | 파일 검색 |
| Grep | 패턴 검색 |
| context7 | 문서 참조 |

### 호출 예시

```bash
# 컴포넌트 문서
> CustomerTable 컴포넌트의 문서를 작성해줘

# API 문서
> updateCustomer Server Action의 문서를 작성해줘

# README 업데이트
> 새 기능에 대한 README 섹션을 추가해줘

# CHANGELOG 업데이트
> 최근 변경사항을 CHANGELOG에 추가해줘
```

### 문서 작성 원칙

1. **명확성**: 전문 용어는 처음 사용 시 설명
2. **일관성**: 용어와 포맷 통일
3. **간결성**: 불필요한 내용 제거
4. **예시 포함**: 코드 예시는 실행 가능하게
5. **한글 우선**: 주석과 문서는 한글로 작성

### 출력 형식 예시

#### 컴포넌트 문서

```markdown
# CustomerTable

## 개요

고객 목록을 표시하는 데이터 테이블 컴포넌트입니다. TanStack Table 기반.

## Props

| Prop | 타입 | 필수 | 기본값 | 설명 |
|------|------|:----:|--------|------|
| data | Customer[] | O | - | 고객 데이터 배열 |
| onEdit | (id: string) => void | X | - | 수정 버튼 클릭 핸들러 |
| onDelete | (id: string) => void | X | - | 삭제 버튼 클릭 핸들러 |

## 사용 예시

\`\`\`tsx
import { CustomerTable } from "./_components/CustomerTable"

export default async function CustomersPage() {
  const customers = await getCustomers()

  return <CustomerTable data={customers} />
}
\`\`\`

## 접근성

- 키보드 네비게이션 지원
- 스크린 리더 호환 (aria-label)
```

---

## 협업 패턴

### 복잡한 기능 개발

```
1. architecture-expert
   └── 전체 구조 설계 (Route, 모델, API 패턴)

2. dev-assistant
   └── 설계 기반 구현

3. performance-expert
   └── 성능 검토 및 최적화

4. docs-writer
   └── 문서화
```

### 패턴별 추천 흐름

#### 새 페이지 추가

```
architecture-expert → dev-assistant → performance-expert
```

#### 기존 코드 리팩토링

```
dev-assistant → performance-expert
```

#### 데이터 모델 변경

```
architecture-expert → dev-assistant
```

#### 문서 업데이트

```
docs-writer (단독)
```

### 호출 예시: 복잡한 기능 개발

```bash
# Step 1: 설계
> @architecture-expert 캠페인 관리 기능을 설계해줘

# Step 2: 구현
> @dev-assistant 위 설계대로 구현해줘

# Step 3: 성능 검토
> @performance-expert 구현된 코드의 성능을 검토해줘

# Step 4: 문서화
> @docs-writer 캠페인 관리 기능 문서를 작성해줘
```

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [GUIDELINES](./GUIDELINES.md) | 플러그인 철학, 역할 정의 |
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 시나리오별 가이드 |
| [SKILLS-ACTIVATION](./SKILLS-ACTIVATION.md) | 스킬 활성화 가이드 |
| [TEAM-ONBOARDING](./TEAM-ONBOARDING.md) | 신규 팀원 온보딩 |
