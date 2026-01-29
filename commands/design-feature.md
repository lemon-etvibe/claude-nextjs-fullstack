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

```markdown
## 기능 설계: {기능명}

### 1. 요구사항 요약
- ...

### 2. 라우팅 구조
- Route Group: (admin)/admin/(protected)/
- URL 패턴: /admin/features, /admin/features/[id]

### 3. 파일 구조
```
src/app/(admin)/
├── _actions/feature.ts
├── _components/
│   ├── FeatureForm.tsx
│   └── FeatureTable.tsx
└── admin/(protected)/features/
    ├── page.tsx
    └── [id]/page.tsx
```

### 4. 데이터 모델
```prisma
model Feature { ... }
```

### 5. Server Actions
- createFeature
- updateFeature
- deleteFeature

### 6. 컴포넌트 목록
| 컴포넌트 | 타입 | 설명 |
| -------- | ---- | ---- |

### 7. 구현 순서
1. Prisma 스키마 추가 → 마이그레이션
2. Server Actions 구현
3. 컴포넌트 구현
4. 페이지 통합
```

## 연계 에이전트

이 명령어는 `architecture-expert` 에이전트의 설계 가이드라인을 기반으로 합니다.
구현은 `dev-assistant` 에이전트가 담당합니다.
