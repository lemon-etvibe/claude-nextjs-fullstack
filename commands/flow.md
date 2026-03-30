---
description: Guided development workflow - chains task, design, validate, commit, PR steps with state tracking
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# /flow Command

Orchestrates the full development workflow by chaining commands with persistent state tracking. Each step is guided and resumable.

## Usage

```
/enf:flow feature               # 기능 개발 플로우 시작
/enf:flow fix                    # 버그 수정 플로우 시작
/enf:flow refactor               # 리팩토링 플로우 시작
/enf:flow resume                 # 중단된 플로우 재개
/enf:flow status                 # 현재 플로우 상태 확인
```

## Flow Types

### feature (전체 흐름)
```
Step 1: /enf:task        → 브랜치 생성 + 작업 정의
Step 2: /enf:design-feature → 아키텍처 설계
Step 3: (구현)            → 사용자가 직접 코드 작성
Step 4: /enf:validate     → 통합 검증 (type + waterfall + review)
Step 5: /enf:commit       → Conventional Commits 형식 커밋
Step 6: /enf:pr           → PR 생성 (→ dev)
```

### fix (설계 생략)
```
Step 1: /enf:task        → 브랜치 생성 + 작업 정의
Step 2: (구현)            → 버그 수정
Step 3: /enf:validate     → 통합 검증
Step 4: /enf:commit       → 커밋
Step 5: /enf:pr           → PR 생성
```

### refactor (리팩토링)
```
Step 1: /enf:task        → 브랜치 생성 + 작업 정의
Step 2: /enf:refactor    → 리팩토링 제안
Step 3: (구현)            → 리팩토링 적용
Step 4: /enf:validate     → 통합 검증
Step 5: /enf:commit       → 커밋
Step 6: /enf:pr           → PR 생성
```

## State Management

### State File: `.local/flow-state.md`

```yaml
---
flow: feature
branch: feat/customer-login
current_step: 3
started_at: "2026-03-12"
task_description: "고객 로그인 기능 구현"
steps:
  task: completed
  design: completed
  implement: in_progress
  validate: pending
  commit: pending
  pr: pending
---
```

### State Lifecycle

1. **Start**: `/enf:flow feature` creates state file, begins Step 1
2. **Progress**: Each step completion updates `current_step` and step status
3. **Pause**: User can stop at any time; state persists in `.local/flow-state.md`
4. **Resume**: `/enf:flow resume` reads state file and continues from `current_step`
5. **Complete**: After final step, state file is archived or removed

## Step Execution Rules

### Automatic Steps
Steps that invoke other commands are executed by guiding Claude to run the appropriate command:
- Read the state file to determine current step
- Execute the corresponding command's workflow
- Update state on completion
- Announce the next step

### Manual Steps (implement)
The "implement" step is user-driven:
- Announce: "구현 단계입니다. 코드를 작성하세요."
- Provide context from previous steps (design output, task description)
- When user signals completion (e.g., "구현 완료", "다음 단계"), advance to next step

### Step Failure
If a step fails (e.g., `/enf:validate` finds errors):
- Do NOT advance to next step
- Show error details and fix suggestions
- User fixes issues, then re-runs current step
- State remains at current step until it passes

## Workflow

### Starting a Flow

```bash
# 1. 기존 플로우 확인
if [[ -f ".local/flow-state.md" ]]; then
  echo "⚠️ 진행 중인 플로우가 있습니다."
  echo "  /enf:flow resume  — 이어서 진행"
  echo "  /enf:flow status  — 상태 확인"
  # Ask: 기존 플로우를 폐기하고 새로 시작할까요?
fi

# 2. 상태 파일 생성
mkdir -p .local
# Write flow-state.md with initial state

# 3. Step 1 시작
echo "🚀 feature 플로우를 시작합니다."
echo "Step 1/6: 작업 정의 (/enf:task)"
# Execute /enf:task workflow
```

### Resuming a Flow

```bash
# 1. 상태 파일 읽기
# 2. current_step 확인
echo "📋 플로우 재개: ${flow} (Step ${current_step})"
echo "브랜치: ${branch}"
echo "다음 단계: ${next_step_name}"
# 3. 해당 단계부터 진행
```

### Status Check

```markdown
## Flow Status

| Step | Status | Command |
|------|--------|---------|
| 1. Task | ✅ Completed | /enf:task |
| 2. Design | ✅ Completed | /enf:design-feature |
| 3. Implement | 🔄 In Progress | (manual) |
| 4. Validate | ⏳ Pending | /enf:validate |
| 5. Commit | ⏳ Pending | /enf:commit |
| 6. PR | ⏳ Pending | /enf:pr |

**Branch**: feat/customer-login
**Started**: 2026-03-12
```

## .gitignore

Ensure `.local/` is in `.gitignore` to prevent state files from being committed:

```
# Flow state files
.local/
```

## Related Commands

- `/enf:task` — 작업 정의 + 브랜치 생성
- `/enf:design-feature` — 아키텍처 설계
- `/enf:validate` — 통합 검증
- `/enf:commit` — 커밋
- `/enf:pr` — PR 생성
- `/enf:release` — 릴리즈 플로우 (별도)
