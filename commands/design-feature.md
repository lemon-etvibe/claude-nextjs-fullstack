---
description: Architecture design for new features - routing, data model, and component structure decisions
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
---

# /design-feature Command

Designs the architecture before adding a new feature.

## Usage

```
/design-feature "<feature description>"
/design-feature "고객 관리 CRUD"
/design-feature "인플루언서 검색 필터"
```

## Design Process

### 1. Requirements Analysis

First, identify the following:

- Feature purpose and user stories
- Required data and relationships
- UI/UX requirements
- Authentication/authorization requirements

### 2. Route Group Decision

| Condition | Route Group | Example |
| -------------------- | ---------------------------- | ----------------------- |
| Admin + No auth required | `(admin)/admin/(auth)/` | login |
| Admin + Auth required | `(admin)/admin/(protected)/` | dashboard, customers |
| Site + Header/Footer | `(site)/(main)/` | home, influencers, blog |
| Site + Auth screen | `(site)/(auth)/` | login, register |
| Site + Auth required | `(site)/(customer)/` | mypage |

### 3. File Structure Design

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

### 4. Data Model Design

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

### 5. Server Action vs API Route Decision

| Use Case | Choice | Reason |
| ------------- | --------------- | ------------------------------------ |
| Form submission | Server Action | Progressive Enhancement, cache invalidation |
| CRUD operations | Server Action | Auth integration, revalidatePath |
| File upload | API Route | Streaming, multipart/form-data |
| External webhooks | API Route | POST endpoint required |
| External API integration | API Route | Secret key management, timeouts |

### 6. Component Classification

| Scope | Location | Example |
| ---------------- | ---------------------- | --------------------------- |
| Page-specific | `page/_components/` | CustomerTable, CustomerForm |
| Route Group shared | `(group)/_components/` | AdminShell, SiteHeader |
| Global shared | `src/components/` | Button, Card (shadcn/ui) |

### 7. Performance Considerations

- [ ] Parallelize independent data requests (Promise.all)
- [ ] Determine Suspense boundary placement
- [ ] Cache strategy (ISR/SSG/Dynamic)
- [ ] Dynamic import for heavy components

## Output Format

Output the design result as a **Handoff Artifact**. This document should be at a level where dev-assistant can immediately begin implementation.

> **Handoff Artifact detailed format**: See the "Handoff Artifact" section in the `architecture-expert` agent documentation

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

### Required Items

- **Error Handling** section included -- Prisma error cases, authentication failures, 404, etc.
- **Component type** specified -- SC (Server Component) / CC (Client Component)
- **Implementation order** checklist -- Determines dev-assistant's work sequence

## Related Agents

This command is based on the `architecture-expert` agent's design guidelines and Handoff Artifact format.
After design completion, inform the user:

> Pass the Handoff Artifact to dev-assistant to begin implementation.
> Example: `@dev-assistant 위 Handoff Artifact 기반으로 구현해줘. 구현 순서 1번부터.`
