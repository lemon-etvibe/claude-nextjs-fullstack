---
description: 테스트 실행 및 테스트 코드 생성 - Vitest, Testing Library, Playwright
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
skills:
  - testing
---

# /test 명령어

테스트를 실행하거나 소스 파일에 맞는 테스트 코드를 자동 생성합니다.

> **활용 스킬**: `testing` 스킬로 Vitest/Testing Library/Playwright 패턴 참조

## 사용법

```
/test                                    # 전체 테스트 실행
/test <파일경로>                          # 해당 파일의 테스트 생성
/test src/app/(admin)/_actions/customer.ts  # Server Action 테스트 생성
/test src/app/(admin)/_components/CustomerTable.tsx  # 컴포넌트 테스트 생성
/test --e2e                              # Playwright E2E 실행
/test --coverage                         # 커버리지 포함 실행
/test --setup                            # 테스트 환경 초기 설정
```

## 워크플로우

### 1. 테스트 환경 확인

```bash
# vitest 설치 여부 확인
pnpm list vitest 2>/dev/null

# playwright 설치 여부 확인
pnpm list @playwright/test 2>/dev/null
```

미설치 시 `--setup` 모드 안내.

### 2. --setup 모드 (초기 설정)

최초 1회 실행. 테스트 환경을 자동 구성합니다.

```bash
# 1. 의존성 설치
pnpm add -D vitest @vitejs/plugin-react jsdom \
  @testing-library/react @testing-library/jest-dom @testing-library/user-event

# 2. E2E (선택)
pnpm add -D @playwright/test
pnpm exec playwright install chromium
```

생성 파일:
- `vitest.config.ts` — Vitest 설정 (path alias, jsdom, coverage)
- `playwright.config.ts` — Playwright 설정 (webServer 포함)
- `src/test/setup.ts` — Testing Library setup
- `src/test/mocks.ts` — 중앙 mock (auth, prisma, headers)
- `src/test/helpers.ts` — FormData 헬퍼, mockSession
- `package.json` scripts 추가

### 3. 테스트 실행 모드 (기본)

인자 없이 호출 시 전체 테스트 실행:

```bash
# 전체 테스트 (watch 모드 아님)
pnpm vitest run

# 특정 파일
pnpm vitest run src/app/(admin)/_actions/__tests__/customer.test.ts

# 커버리지 포함
pnpm vitest run --coverage
```

### 4. 테스트 생성 모드 (파일 지정)

소스 파일 경로를 지정하면 대상을 분석하여 테스트 보일러플레이트를 생성합니다.

**분류 단계:**

1. 대상 파일 읽기 (`Read`)
2. 파일 분류 (아래 기준)
3. `__tests__/` 디렉토리에 테스트 파일 생성 (`Write`)
4. 중앙 mock import 필요 시 자동 추가

**테스트 케이스 생성 기준:**

| 분류 | 생성할 테스트 |
|------|-------------|
| Server Action | 인증 실패, 검증 실패, 성공, DB 에러 (4개) |
| Component | 기본 렌더링, 사용자 인터랙션 (2~3개) |
| Utility | 정상 입력, 엣지 케이스 (2~3개) |

### 5. E2E 테스트 모드 (--e2e)

```bash
# 전체 E2E
pnpm exec playwright test

# 대화형 UI
pnpm exec playwright test --ui

# 특정 파일
pnpm exec playwright test e2e/login.spec.ts
```

## 파일 자동 분류 기준

2단계로 분류합니다:

### 1단계: 경로 패턴 매칭

| 소스 경로 패턴 | 분류 | 테스트 위치 |
|---------------|------|------------|
| `_actions/*.ts` | Server Action | `_actions/__tests__/*.test.ts` |
| `_components/*.tsx` | Component | `_components/__tests__/*.test.tsx` |
| `_lib/*.ts` | Utility | `_lib/__tests__/*.test.ts` |
| `lib/*.ts` | Utility | `lib/__tests__/*.test.ts` |
| `components/ui/*.tsx` | Component | `components/ui/__tests__/*.test.tsx` |

### 2단계: 파일 내용 분석 (경로로 불명확 시)

| 파일 내용 | 분류 |
|----------|------|
| `"use server"` 지시문 포함 | Server Action |
| `.tsx` + JSX export (`export default function`) | Component |
| 그 외 | Utility |

## 출력 형식

### 테스트 실행 결과

```markdown
## 테스트 실행 결과

### 요약
- **전체**: N개
- **통과**: N개 ✅
- **실패**: N개 ❌
- **건너뜀**: N개 ⏭️

### 실패한 테스트

#### 1. {테스트 이름}
- **파일**: path/to/test.ts:N
- **원인**: ...
- **해결 방안**: ...

### 커버리지 (--coverage 사용 시)

| 파일 | 구문 | 분기 | 함수 | 라인 |
| ---- | ---- | ---- | ---- | ---- |
```

### 테스트 생성 결과

```markdown
## 테스트 생성 결과: {파일명}

### 분류
- **유형**: Server Action / Component / Utility
- **분류 근거**: 경로 매칭 / 내용 분석

### 생성된 파일
- `path/to/__tests__/filename.test.ts`

### 생성된 테스트 케이스
1. {테스트 이름} - {설명}
2. {테스트 이름} - {설명}
3. {테스트 이름} - {설명}

### 다음 단계
1. `pnpm vitest run {경로}` — 테스트 실행
2. 필요 시 테스트 케이스 추가/수정
```

## 연계 명령어

- `/enf:code-review` — 테스트 전 코드 품질 점검
- `/enf:type-check` — 타입 검증
- `/enf:commit` — 테스트 추가 커밋

## 연계 스킬

- `testing` — Vitest, Testing Library, Playwright, Server Action, MSW 상세 패턴
