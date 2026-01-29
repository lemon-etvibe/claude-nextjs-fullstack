---
name: code-review
description: 코드 품질 검사 - TypeScript, 성능, 보안, 베스트 프랙티스 점검
allowed-tools:
  - Read
  - Glob
  - Grep
---

# /code-review 명령어

지정된 파일 또는 디렉토리의 코드를 리뷰합니다.

## 사용법

```
/code-review <파일경로|디렉토리>
/code-review src/app/(admin)/_actions/customer.ts
/code-review src/components/ui
```

## 리뷰 체크리스트

### 1. TypeScript 품질

- [ ] `any` 타입 사용 여부 (unknown 또는 구체적 타입으로 대체)
- [ ] strict 모드 준수 여부
- [ ] 타입 추론 가능한 곳의 불필요한 타입 선언
- [ ] 제네릭 활용 적절성

### 2. React/Next.js 패턴

- [ ] 불필요한 'use client' 지시문
- [ ] Server Components 우선 사용 여부
- [ ] 적절한 Suspense 경계 설정
- [ ] metadata export (페이지의 경우)

### 3. 성능 최적화

- [ ] **순차 await waterfall** - Promise.all() 병렬화 검토
- [ ] **무거운 컴포넌트 dynamic import** - 모달, 에디터, 차트
- [ ] **RSC → CC 경계 최소 데이터 전달**
- [ ] **lucide-react 개별 파일 import**
- [ ] **useState 초기값 lazy init 검토**

### 4. Server Action 패턴 (해당 시)

- [ ] 'use server' 지시문 존재
- [ ] Better Auth 인증 검사
- [ ] Zod 스키마 검증
- [ ] revalidatePath 캐시 무효화
- [ ] 적절한 에러 반환 형식

### 5. Prisma 쿼리 (해당 시)

- [ ] select로 필요한 필드만 조회
- [ ] N+1 쿼리 방지 (include 사용)
- [ ] 적절한 인덱스 활용

### 6. 보안

- [ ] 사용자 입력 검증
- [ ] SQL 인젝션 방지 (Prisma 사용)
- [ ] XSS 방지
- [ ] 민감 정보 노출 없음

### 7. 코드 스타일

- [ ] Import 순서 규칙 (React/Next → 외부 → 내부 → 타입)
- [ ] 컴포넌트 PascalCase, 유틸 camelCase
- [ ] 접근성 (a11y) 속성

## 출력 형식

리뷰 결과를 다음 형식으로 제공하세요:

```markdown
## 코드 리뷰 결과: {파일명}

### 발견된 이슈

#### 심각 (즉시 수정 필요)
- 이슈 설명 및 위치
- 수정 제안

#### 경고 (권장 수정)
- 이슈 설명 및 위치
- 수정 제안

#### 정보 (선택적 개선)
- 개선 제안

### 잘된 점
- 좋은 패턴 언급

### 총평
전체적인 코드 품질 평가
```

## 연계 에이전트

이 명령어는 `dev-assistant` 에이전트의 코드 리뷰 체크리스트를 기반으로 합니다.
