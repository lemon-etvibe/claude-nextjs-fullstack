---
description: Task definition and Git branch creation - task start workflow
allowed-tools:
  - Bash
  - Read
  - Glob
---

# /task Command

Defines a new task and creates a Git branch when starting work.

## Usage

```
/task "<task description>"
/task "로그인 페이지 구현"
/task "고객 목록 필터 기능 추가"
/task "버그 수정: 이메일 유효성 검사"
```

## Workflow

### 1. Task Type Classification

| Prefix | Type | Description |
| ------ | ---- | ---- |
| `feat/` | Feature | New feature |
| `fix/` | Bug Fix | Bug fix |
| `refactor/` | Refactor | Code improvement (no functional changes) |
| `docs/` | Documentation | Documentation creation/modification |
| `style/` | Style | Code style changes |
| `test/` | Test | Add/modify tests |
| `chore/` | Chore | Build, configuration, and other miscellaneous |

### 2. Branch Naming Rules

```
<type>/<short-description>

예시:
feat/customer-login
fix/email-validation
refactor/campaign-table
docs/api-readme
```

### 3. Execution Steps

1. Check current branch status
2. **Warning: Check if based on dev branch**
3. Classify task type
4. Generate branch name
5. Create new branch from dev

```bash
# 현재 상태 확인
git status
CURRENT_BRANCH=$(git branch --show-current)

# ⚠️ 현재 브랜치가 dev가 아니면 경고
if [[ "$CURRENT_BRANCH" != "dev" ]]; then
  echo "⚠️ 경고: 현재 브랜치가 '$CURRENT_BRANCH'입니다."
  echo "   새 작업 브랜치는 'dev'에서 분리하는 것이 권장됩니다."
  echo ""
  echo "   계속하시겠습니까?"
  echo "   - Y: dev로 이동 후 브랜치 생성 (권장)"
  echo "   - N: 현재 브랜치에서 분리 (비권장)"
  echo "   - C: 취소"
  # → AskUserQuestion으로 확인 필요
fi

# dev 브랜치 확인 (없으면 main에서 생성)
if ! git show-ref --verify --quiet refs/heads/dev; then
  git checkout main
  git pull origin main
  git checkout -b dev
  git push -u origin dev
fi

# dev 최신화
git checkout dev
git pull origin dev

# 새 브랜치 생성
git checkout -b feat/customer-login
```

> **Important**: All work branches must be created from `dev`. Creating branches directly from `main` can cause PR target conflicts.

### 4. Task Context Setup

After branch creation, verify/inform the following:

- Related file locations (Route Group, components, etc.)
- Required data models
- Existing patterns to reference

## Branch Naming Convention

### DO

- Use lowercase
- Separate words with hyphens
- Keep descriptions concise and clear
- Use English

### DON'T

- Use Korean characters
- Use overly long names (keep within 3-4 words)
- Use special characters (except hyphens)
- Use only issue numbers

## Output Format

```markdown
## 작업 시작: {작업 설명}

### 브랜치 정보
- **유형**: Feature
- **브랜치명**: `feat/customer-login`
- **기반 브랜치**: dev

### 실행된 명령어
```bash
git checkout dev
git pull origin dev
git checkout -b feat/customer-login
```

### 작업 컨텍스트
- **Route Group**: (admin)/admin/(protected)/
- **관련 파일**:
  - `src/app/(admin)/_actions/auth.ts`
  - `src/app/(admin)/_components/LoginForm.tsx`

### 다음 단계
1. 기능 구현
2. `/commit` - 변경사항 커밋
3. `/push` - 원격 푸시
4. `/pr` - PR 생성 (→ dev 브랜치로 머지)
```

## Related Commands

- `/design-feature` - Feature design (for complex tasks)
- `/commit` - Create commit
- `/push` - Push to remote
- `/pr` - Create PR
