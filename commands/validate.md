---
description: Pre-PR integrated validation - TypeScript, waterfall patterns, code review in one pass
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
skills:
  - vercel-react-best-practices
  - coding-conventions
  - error-handling
---

# /validate Command

Runs all quality checks in a single pass before PR creation. Combines type-check, waterfall-check, and code-review into one unified validation.

## Usage

```
/enf:validate                    # 변경된 파일 자동 감지
/enf:validate src/app/(admin)/   # 특정 경로 지정
```

## Workflow

### 1. Scope Detection

```bash
# 변경된 파일 목록 수집 (staged + unstaged)
git diff --name-only --diff-filter=ACMR HEAD
git diff --name-only --diff-filter=ACMR --staged
```

Only `.ts` / `.tsx` files are validated. If a path argument is given, scope is limited to that path.

### 2. TypeScript Strict Verification

```bash
pnpm tsc --noEmit
```

Check for:
- `any` type usage → suggest `unknown` with type guard
- Missing return types on exported functions
- Unsafe `as` assertions → suggest type guard pattern

### 3. Waterfall Pattern Detection

Scan all changed files for sequential `await` patterns that could be parallelized:

```typescript
// ❌ Waterfall
const users = await getUsers()
const posts = await getPosts()

// ✅ Parallel
const [users, posts] = await Promise.all([getUsers(), getPosts()])
```

### 4. Code Review (Security + Performance + Patterns)

| Category | Checks |
|----------|--------|
| Security | SQL injection, XSS, exposed secrets, missing auth in Server Actions |
| Performance | Unnecessary 'use client', missing Suspense boundaries, large bundle imports |
| Patterns | Import order, naming conventions, error handling patterns |

### 5. Results Summary

Output a structured report:

```markdown
## Validation Results

### TypeScript  [PASS/FAIL]
- ✅ No type errors
- ⚠️ 2 `any` usages found (src/lib/utils.ts:15, src/app/_actions/customer.ts:32)

### Waterfall   [PASS/FAIL]
- ⚠️ 1 sequential await pattern (src/app/(admin)/page.tsx:20-22)

### Code Review [PASS/FAIL]
- ✅ Security: No issues
- ⚠️ Performance: lucide-react barrel import (src/app/_components/Header.tsx:3)
- ✅ Patterns: Follows conventions

### Summary
2 warnings, 0 errors — PR creation OK with fixes recommended
```

## Decision Rules

| Result | Action |
|--------|--------|
| All PASS | "PR 생성 가능합니다. `/enf:commit` → `/enf:pr` 진행하세요." |
| Warnings only | "PR 생성 가능하지만 수정을 권장합니다." + 수정 가이드 |
| Any FAIL | "PR 생성 전 수정이 필요합니다." + 수정 가이드 |

## Related Commands

- `/enf:type-check` — TypeScript 검증만 실행
- `/enf:waterfall-check` — Waterfall 패턴만 검출
- `/enf:code-review` — 코드 리뷰만 실행
- `/enf:commit` — 검증 통과 후 커밋
- `/enf:pr` — PR 생성
