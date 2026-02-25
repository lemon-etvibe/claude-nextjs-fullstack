---
description: Test execution and test code generation - Vitest, Testing Library, Playwright
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

# /test Command

Runs tests or auto-generates test code matching the source file.

> **Skill used**: References Vitest/Testing Library/Playwright patterns via the `testing` skill

## Usage

```
/test                                    # 전체 테스트 실행
/test <file-path>                        # 해당 파일의 테스트 생성
/test src/app/(admin)/_actions/customer.ts  # Server Action 테스트 생성
/test src/app/(admin)/_components/CustomerTable.tsx  # 컴포넌트 테스트 생성
/test --e2e                              # Playwright E2E 실행
/test --coverage                         # 커버리지 포함 실행
/test --setup                            # 테스트 환경 초기 설정
```

## Workflow

### 1. Check Test Environment

```bash
# vitest 설치 여부 확인
pnpm list vitest 2>/dev/null

# playwright 설치 여부 확인
pnpm list @playwright/test 2>/dev/null
```

If not installed, guide to `--setup` mode.

### 2. --setup Mode (Initial Setup)

Run once initially. Automatically configures the test environment.

```bash
# 1. 의존성 설치
pnpm add -D vitest @vitejs/plugin-react jsdom \
  @testing-library/react @testing-library/jest-dom @testing-library/user-event

# 2. E2E (선택)
pnpm add -D @playwright/test
pnpm exec playwright install chromium
```

Generated files:
- `vitest.config.ts` -- Vitest configuration (path alias, jsdom, coverage)
- `playwright.config.ts` -- Playwright configuration (includes webServer)
- `src/test/setup.ts` -- Testing Library setup
- `src/test/mocks.ts` -- Central mocks (auth, prisma, headers)
- `src/test/helpers.ts` -- FormData helpers, mockSession
- `package.json` scripts added

### 3. Test Execution Mode (default)

When called without arguments, runs all tests:

```bash
# 전체 테스트 (watch 모드 아님)
pnpm vitest run

# 특정 파일
pnpm vitest run src/app/(admin)/_actions/__tests__/customer.test.ts

# 커버리지 포함
pnpm vitest run --coverage
```

### 4. Test Generation Mode (file specified)

When a source file path is specified, analyzes the target and generates test boilerplate.

**Classification steps:**

1. Read target file (`Read`)
2. Classify file (criteria below)
3. Generate test file in `__tests__/` directory (`Write`)
4. Auto-add central mock imports if needed

**Test case generation criteria:**

| Classification | Tests to Generate |
|------|-------------|
| Server Action | Auth failure, validation failure, success, DB error (4 cases) |
| Component | Default render, user interaction (2-3 cases) |
| Utility | Normal input, edge cases (2-3 cases) |

### 5. E2E Test Mode (--e2e)

```bash
# 전체 E2E
pnpm exec playwright test

# 대화형 UI
pnpm exec playwright test --ui

# 특정 파일
pnpm exec playwright test e2e/login.spec.ts
```

## Automatic File Classification Criteria

Classification is done in 2 steps:

### Step 1: Path Pattern Matching

| Source Path Pattern | Classification | Test Location |
|---------------|------|------------|
| `_actions/*.ts` | Server Action | `_actions/__tests__/*.test.ts` |
| `_components/*.tsx` | Component | `_components/__tests__/*.test.tsx` |
| `_lib/*.ts` | Utility | `_lib/__tests__/*.test.ts` |
| `lib/*.ts` | Utility | `lib/__tests__/*.test.ts` |
| `components/ui/*.tsx` | Component | `components/ui/__tests__/*.test.tsx` |

### Step 2: File Content Analysis (when path is ambiguous)

| File Content | Classification |
|----------|------|
| Contains `"use server"` directive | Server Action |
| `.tsx` + JSX export (`export default function`) | Component |
| Other | Utility |

## Output Format

### Test Execution Results

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

### Test Generation Results

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

## Related Commands

- `/enf:code-review` -- Code quality review before testing
- `/enf:type-check` -- Type verification
- `/enf:commit` -- Commit test additions

## Related Skills

- `testing` -- Detailed patterns for Vitest, Testing Library, Playwright, Server Action, MSW
