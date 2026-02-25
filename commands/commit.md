---
description: Git commit creation - Conventional Commits format
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# /commit Command

Analyzes changes and creates a commit in Conventional Commits format.

> **Note**: If the external plugin `commit-commands` is installed, that plugin takes priority.
> This command is provided as a fallback.

## Usage

```
/commit                         # 자동 커밋 메시지 생성
/commit "<메시지>"              # 직접 메시지 지정
/commit --amend                 # 이전 커밋 수정
```

## Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type

| Type | Description |
| ---- | ---- |
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code formatting (no functional changes) |
| `refactor` | Code refactoring |
| `test` | Add/modify tests |
| `chore` | Build, configuration, and other miscellaneous |
| `perf` | Performance improvements |

### Scope (optional)

Area affected by the change:

- `auth` - Authentication related
- `customer` - Customer related
- `campaign` - Campaign related
- `ui` - UI components
- `prisma` - Database
- `api` - API related

### Examples

```
feat(customer): 고객 목록 필터 기능 추가

- 상태별 필터 추가
- 가입일 기준 정렬 추가
- 검색 기능 구현

Closes #123
```

## Workflow

### 1. Check Changes

```bash
git status
git diff --staged
git diff
```

### 2. Analyze Changes

- Which files were changed?
- What type of change is it? (feat/fix/refactor, etc.)
- What is the scope of the change?

### 3. Staging

```bash
# 특정 파일
git add src/app/(admin)/_actions/customer.ts

# 관련 파일 모두
git add src/app/(admin)/
```

### 4. Create Commit

```bash
git commit -m "feat(customer): 고객 검색 기능 추가"
```

## Commit Message Writing Guide

### DO

- Use present tense ("Add" not "Added")
- Lowercase first letter (English) or Korean
- Subject line within 50 characters
- Explain what and why was changed

### DON'T

- Do not end with a period
- Do not use self-evident words like "commit"
- Avoid overly vague descriptions ("fix", "update")

## Output Format

```markdown
## 커밋 생성

### 변경사항 분석
- **변경된 파일**: N개
- **추가**: N줄
- **삭제**: N줄

### 변경 파일 목록
- `src/app/(admin)/_actions/customer.ts` - 고객 검색 액션 추가
- `src/app/(admin)/_components/CustomerSearch.tsx` - 검색 UI 컴포넌트

### 생성된 커밋
```bash
git add src/app/(admin)/_actions/customer.ts src/app/(admin)/_components/CustomerSearch.tsx
git commit -m "feat(customer): 고객 검색 기능 추가"
```

### 결과
- **커밋 해시**: abc1234
- **브랜치**: feat/customer-search
```

## Related Commands

- `/task` - Start a task
- `/push` - Push to remote
- `/pr` - Create PR
