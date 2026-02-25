# 플러그인 가이드라인

etvibe-nextjs-fullstack (enf) 플러그인의 철학, 역할 정의, 확장 가이드라인입니다.

---

## 목차

- [플러그인 철학](#플러그인-철학)
- [역할 정의](#역할-정의)
- [워크플로우 원칙](#워크플로우-원칙)
- [품질 기준](#품질-기준)

---

## 플러그인 철학

### 핵심 가치

| 가치 | 설명 |
|------|------|
| **일관성** | 팀 전체가 동일한 패턴과 컨벤션을 따름 |
| **효율성** | 반복 작업 자동화, 빠른 피드백 루프 |
| **품질** | 코드 리뷰, 타입 안전성, 성능 최적화 내장 |
| **학습 곡선 최소화** | 명확한 가이드와 자동화된 체크 |

### 설계 원칙

1. **Convention over Configuration**
   - 설정보다 관례 우선
   - 프로젝트 구조, 네이밍, 패턴 표준화

2. **Progressive Enhancement**
   - Server Components 우선
   - 'use client' 최소화
   - 점진적으로 인터랙티브 기능 추가

3. **Co-location**
   - 관련 코드를 가까이 배치
   - `_actions/`, `_components/`, `_lib/` 패턴

4. **Fail Fast**
   - 빠른 에러 감지 (TypeScript strict, Hooks)
   - 문제 발생 시 즉각적인 피드백

---

## 역할 정의

> **Agents, Commands, Skills 상세 목록**: [README.md](../README.md#whats-included)

### Agent 선택 기준

```
[질문] 무엇을 해야 하는가?

├── 새 기능/페이지 설계 필요
│   └── architecture-expert → 설계 완료 후 → dev-assistant
│
├── 코드 구현/수정 필요
│   └── dev-assistant
│
├── 성능 문제/최적화 필요
│   └── performance-expert
│
└── 문서 작성 필요
    └── docs-writer
```

> **커맨드 빠른 참조**: [COMMANDS-REFERENCE.md](./COMMANDS-REFERENCE.md)

---

## 워크플로우 원칙

### 브랜치 전략

```
                              ┌──────────┐
                              │   main   │ ← 프로덕션 (보호됨)
                              └────▲─────┘
                                   │
                          PR (dev→main) + 릴리스 태그
                                   │
                              ┌────┴─────┐
                              │   dev    │ ← 통합 브랜치 (스테이징)
                              └────▲─────┘
                                   │
                          PR (feature→dev) + CHANGELOG 업데이트
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
         feat/*               fix/*              refactor/*
              ▲
              │
         /enf:task (dev에서 분기)
```

| 브랜치 | 역할 | 직접 푸시 |
|--------|------|:---------:|
| `main` | 프로덕션 릴리스 | ❌ (PR 필수) |
| `dev` | 개발 통합 브랜치 | ❌ (PR 권장) |
| `feat/*`, `fix/*` 등 | 기능 브랜치 | ✅ |

### 표준 개발 플로우

```
[작업 시작]
    │
    ▼
/enf:task "기능명" ─── 브랜치 생성 (dev → feat/feature-name)
    │
    ▼
/enf:design-feature ─── (복잡한 기능일 경우) 설계
    │
    ▼
[코드 구현] ─── dev-assistant
    │
    ▼
/enf:code-review ─── 품질 검사
    │
    ▼
/enf:test ─── 테스트 실행/생성
    │
    ▼
/enf:commit ─── Conventional Commit
    │
    ▼
/enf:push ─── 안전 체크 후 푸시
    │
    ▼
/enf:pr ─── PR 생성 (→ dev)
    │
    ▼
[머지] ─── CHANGELOG [Unreleased] 자동 업데이트
```

### 릴리스 플로우

```
[dev 브랜치에서]
    │
    ▼
/enf:pr --release ─── dev → main PR 생성 (버전 지정)
    │
    ▼
[PL 승인 후 머지]
    │
    ▼
[자동화] ─── CHANGELOG 버전 확정
         ─── Git 태그 (vX.X.X)
         ─── GitHub Release 생성
```

### Agent 협업 패턴

#### 복잡한 기능 개발

```
1. architecture-expert → 전체 구조 설계
   - Route Group 결정
   - 데이터 모델 설계
   - API 패턴 선택

2. dev-assistant → 구현
   - 컴포넌트 작성
   - Server Actions 구현
   - 테스트 작성

3. performance-expert → 성능 검토
   - 번들 크기 확인
   - Waterfall 패턴 검출
   - Core Web Vitals 확인

4. docs-writer → 문서화
   - API 문서 생성
   - 컴포넌트 문서 작성
```

#### 버그 수정

```
1. dev-assistant → 원인 분석 및 수정
2. /enf:code-review → 수정 검증
3. /enf:commit → 버그 수정 커밋
```

#### 리팩토링

```
1. /enf:refactor → 리팩토링 제안
2. dev-assistant → 적용
3. /enf:type-check → 타입 검증
4. /enf:code-review → 최종 검토
```

---

## 품질 기준

### 코드 체크리스트

#### 기본 품질

- [ ] TypeScript strict 모드 준수
- [ ] `any` 타입 사용 금지 (`unknown` 사용)
- [ ] 불필요한 'use client' 없음
- [ ] Better Auth 인증 검사 적용
- [ ] 적절한 에러 처리
- [ ] Import 순서 규칙 준수

#### 성능

- [ ] 순차 await waterfall 없음 (Promise.all 사용)
- [ ] 무거운 컴포넌트 dynamic import (모달/에디터/차트)
- [ ] RSC → CC 최소 데이터 전달
- [ ] lucide-react 아이콘 개별 import

#### 테스트

- [ ] Server Action 테스트 작성 (인증, 검증, 성공, 에러)
- [ ] 클라이언트 컴포넌트 테스트 작성 (렌더링, 인터랙션)
- [ ] 중요 플로우 E2E 테스트 작성

#### Prisma

- [ ] select로 필요한 필드만 조회
- [ ] N+1 쿼리 방지 (include 사용)
- [ ] 적절한 인덱스 설정

### 문서 체크리스트

- [ ] 한글 문서, 영어 기술 용어
- [ ] 코드 예시 실행 가능
- [ ] 관련 문서 링크 확인
- [ ] 마크다운 렌더링 정상

---

## 유지보수 가이드라인

> **플러그인 확장 방법**: Agent, Command, Skill, Hook 추가는 [CUSTOMIZATION.md](./CUSTOMIZATION.md)를 참조하세요.

### 문서 업데이트 규칙

#### 새 기능 추가 시

1. 관련 Agent/Command/Skill 문서 업데이트
2. CHANGELOG.md에 변경사항 추가
3. README.md 연계 확인
4. GUIDELINES.md 역할 정의 업데이트

#### 버그 수정 시

1. CHANGELOG.md Fixed 섹션에 추가
2. 관련 문서 수정 (있을 경우)

### 주기적 리뷰

| 주기 | 작업 |
|------|------|
| 릴리스마다 | CHANGELOG 업데이트 |
| 월간 | 코드 예시 유효성 검토 |
| 분기별 | 문서 구조/링크 점검 |

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [README](../README.md) | 빠른 시작 |
| [COMMANDS-REFERENCE](./COMMANDS-REFERENCE.md) | 커맨드 빠른 참조 |
| [CUSTOMIZATION](./CUSTOMIZATION.md) | 플러그인 확장 가이드 |
| [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 상세 매뉴얼 |
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 시나리오별 가이드 |
| [TROUBLESHOOTING](./TROUBLESHOOTING.md) | 문제 해결 가이드 |
| [CHANGELOG](../CHANGELOG.md) | 버전 이력 |
