---
description: 새로운 기능의 아키텍처 설계 - 라우팅, 데이터 모델, 컴포넌트 구조 결정
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
---

# /design-feature 명령어

새로운 기능을 추가하기 전에 아키텍처를 설계합니다.

## 사용법

```
/design-feature "<기능 설명>"
/design-feature "고객 관리 CRUD"
/design-feature "인플루언서 검색 필터"
```

## 설계 프로세스

### 1. 요구사항 분석

먼저 다음을 파악하세요:

- 기능의 목적과 사용자 스토리
- 필요한 데이터와 관계
- UI/UX 요구사항
- 인증/권한 요구사항

### 2. Route Group 결정

| 조건                 | Route Group                  | 예시                    |
| -------------------- | ---------------------------- | ----------------------- |
| Admin + 인증 불필요  | `(admin)/admin/(auth)/`      | login                   |
| Admin + 인증 필요    | `(admin)/admin/(protected)/` | dashboard, customers    |
| Site + Header/Footer | `(site)/(main)/`             | home, influencers, blog |
| Site + 인증 화면     | `(site)/(auth)/`             | login, register         |
| Site + 인증 필요     | `(site)/(customer)/`         | mypage                  |

### 3. 파일 구조 설계

```
src/app/(<route-group>)/
├── _actions/           # Server Actions
│   └── <feature>.ts
├── _components/        # 기능 전용 컴포넌트
│   ├── <Feature>Form.tsx
│   ├── <Feature>List.tsx
│   └── <Feature>Card.tsx
├── _lib/               # 기능 전용 유틸
│   ├── schemas.ts      # Zod 스키마
│   └── hooks.ts        # React 훅
└── <route>/            # 실제 라우트
    ├── page.tsx
    ├── [id]/
    │   └── page.tsx
    └── loading.tsx
```

### 4. 데이터 모델 설계

```prisma
model Feature {
  id        String   @id @default(cuid())
  // 필드 정의
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // 관계 정의
  @@index([...])  // 검색 패턴 기반 인덱스
}
```

### 5. Server Action vs API Route 결정

| 사용처        | 선택            | 이유                                 |
| ------------- | --------------- | ------------------------------------ |
| 폼 제출       | Server Action   | Progressive Enhancement, 캐시 무효화 |
| CRUD 작업     | Server Action   | 인증 통합, revalidatePath            |
| 파일 업로드   | API Route       | 스트리밍, multipart/form-data        |
| 외부 웹훅     | API Route       | POST 엔드포인트 필요                 |
| 외부 API 연동 | API Route       | 시크릿 키 관리, 타임아웃             |

### 6. 컴포넌트 분류

| 범위             | 위치                   | 예시                        |
| ---------------- | ---------------------- | --------------------------- |
| 페이지 전용      | `페이지/_components/`  | CustomerTable, CustomerForm |
| Route Group 공유 | `(group)/_components/` | AdminShell, SiteHeader      |
| 전체 공유        | `src/components/`      | Button, Card (shadcn/ui)    |

### 7. 성능 고려사항

- [ ] 독립 데이터 요청 병렬화 (Promise.all)
- [ ] Suspense 경계 위치 결정
- [ ] 캐시 전략 (ISR/SSG/Dynamic)
- [ ] 무거운 컴포넌트 dynamic import

## 출력 형식

설계 결과를 **Handoff Artifact** 형식으로 출력합니다. 이 문서는 dev-assistant가 즉시 구현을 시작할 수 있는 수준이어야 합니다.

> **Handoff Artifact 상세 형식**: `architecture-expert` 에이전트 문서의 "Handoff Artifact" 섹션 참조

```markdown
# Handoff: {기능명}

## 1. 요구사항 요약
## 2. 데이터 모델 (Prisma 스키마)
## 3. 파일 구조 (SC/CC 타입 명시)
## 4. Server Actions / API Routes (함수명, 인증, 설명)
## 5. 컴포넌트 목록 (타입, Props)
## 6. 에러 처리 (Prisma 에러 코드, 인증 실패, 404 케이스)
## 7. 구현 순서 (체크리스트)
```

### 필수 항목

- **에러 처리** 섹션 포함 — Prisma 에러 케이스, 인증 실패, 404 등
- **컴포넌트 타입** 명시 — SC (Server Component) / CC (Client Component)
- **구현 순서** 체크리스트 — dev-assistant의 작업 순서 결정

## 연계 에이전트

이 명령어는 `architecture-expert` 에이전트의 설계 가이드라인과 Handoff Artifact 형식을 기반으로 합니다.
설계 완료 후 사용자에게 안내합니다:

> dev-assistant에게 Handoff Artifact를 전달하여 구현을 시작하세요.
> 예: `@dev-assistant 위 Handoff Artifact 기반으로 구현해줘. 구현 순서 1번부터.`
