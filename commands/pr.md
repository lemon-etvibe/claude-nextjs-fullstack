---
description: GitHub Pull Request creation - automatic template application
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# /pr Command

Creates a GitHub Pull Request from the current branch.

## Usage

```
/pr                             # 자동 PR 생성 (→ dev)
/pr --draft                     # Draft PR 생성 (→ dev)
/pr --release                   # 릴리스 PR 생성 (dev → main)
/pr --release --version 1.2.0   # 버전 지정 릴리스 PR
/pr --base <branch>             # 타겟 브랜치 수동 지정
```

## Workflow

### 1. Pre-checks

```bash
# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)

# ⚠️ dev 또는 main 브랜치에서 직접 PR 생성 방지
if [[ "$CURRENT_BRANCH" == "dev" || "$CURRENT_BRANCH" == "main" ]]; then
  echo "⚠️ 경고: '$CURRENT_BRANCH' 브랜치에서 직접 PR을 생성하려고 합니다."
  echo "   작업 브랜치(feat/*, fix/* 등)에서 PR을 생성하는 것이 권장됩니다."
  # → AskUserQuestion으로 계속 여부 확인
fi

# 원격에 푸시되었는지 확인
git log origin/$CURRENT_BRANCH..HEAD --oneline 2>/dev/null

# 이미 PR이 있는지 확인
gh pr list --head $CURRENT_BRANCH
```

### 2. Change Analysis

```bash
# dev와의 차이 확인 (기본)
git log dev..HEAD --oneline

# 변경된 파일 목록
git diff dev...HEAD --stat
```

### 3. PR Creation

> **Important**: The default target is always the `dev` branch. `--base main` is only used for release PRs.

```bash
# ⚠️ --base dev 필수 명시 (기본 브랜치가 main이므로)
gh pr create \
  --base dev \
  --title "feat(customer): 고객 로그인 기능 구현" \
  --body "$(cat <<'EOF'
## 개요

고객 로그인 페이지 및 인증 기능을 구현했습니다.

## 변경사항

- 로그인 폼 UI 구현
- Better Auth 연동
- 세션 관리 설정

## 테스트

- [ ] 로그인 성공 테스트
- [ ] 잘못된 비밀번호 테스트
- [ ] 세션 만료 테스트

## 스크린샷

(해당 시 첨부)

## 체크리스트

- [ ] 코드 리뷰 준비 완료
- [ ] 테스트 통과
- [ ] 문서 업데이트 (필요 시)
EOF
)"
```

## PR Template

```markdown
## 개요

{변경사항 요약 - 1-2문장}

## 변경사항

- {주요 변경 1}
- {주요 변경 2}
- {주요 변경 3}

## 관련 이슈

- Closes #{이슈 번호}

## 테스트

- [ ] {테스트 항목 1}
- [ ] {테스트 항목 2}

## 스크린샷

{UI 변경 시 스크린샷 첨부}

## 체크리스트

- [ ] 코드 리뷰 준비 완료
- [ ] 테스트 통과
- [ ] TypeScript 에러 없음
- [ ] lint 에러 없음
```

## PR Title Convention

Follows Conventional Commits format:

```
<type>(<scope>): <description>

예시:
feat(customer): 고객 로그인 기능 구현
fix(auth): 세션 만료 처리 수정
refactor(campaign): 캠페인 테이블 컴포넌트 분리
```

## Release PR (--release)

Using the `--release` flag creates a release PR from dev to main.

### Prerequisites

- Current branch must be `dev`
- The dev branch must be up to date

### Execution Flow

```bash
# 현재 브랜치 확인
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "dev" ]]; then
  echo "❌ 릴리스 PR은 dev 브랜치에서만 생성할 수 있습니다."
  exit 1
fi

# 버전 결정 (지정되지 않으면 CHANGELOG에서 추출 또는 사용자에게 질문)
# CHANGELOG.md의 [Unreleased] 다음 버전 헤더에서 추출 시도
VERSION="${VERSION:-$(grep -oP '## \[\K[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | head -1)}"
if [[ -z "$VERSION" ]]; then
  echo "⚠️ 버전을 자동으로 결정할 수 없습니다. --version 플래그로 지정하세요."
  echo "   예: /pr --release --version 1.2.0"
  exit 1
fi

# 릴리스 PR 생성
gh pr create \
  --base main \
  --title "release: v${VERSION}" \
  --body "$(cat <<EOF
## 릴리스 v${VERSION}

### CHANGELOG 미리보기

$(sed -n '/## \[Unreleased\]/,/## \[/p' CHANGELOG.md | head -50)

### 체크리스트

- [ ] CHANGELOG 내용 확인
- [ ] 모든 기능 테스트 완료
- [ ] 문서 업데이트 완료
EOF
)"
```

### Release PR Template

```markdown
## 릴리스 v{version}

### CHANGELOG 미리보기

{Unreleased 섹션 내용}

### 체크리스트

- [ ] CHANGELOG 내용 확인
- [ ] 모든 기능 테스트 완료
- [ ] 문서 업데이트 완료
- [ ] 팀 리뷰어 승인
```

## Target Branch Rules

| Scenario | Target Branch | Command |
|------|------------|--------|
| Normal work | `dev` (default) | `/pr` |
| Release | `main` | `/pr --release` |
| Manual specification | Specified branch | `/pr --base <branch>` |

> **Warning**: Running `gh pr create` without `--base` will create a PR targeting the repository default branch (main). Always specify `--base dev`.

## Automatic Analysis

The following are automatically analyzed during PR creation:

1. **Commit message analysis** - Generates PR title and body draft
2. **Changed file analysis** - Summarizes changes
3. **Impact scope identification** - Identifies related feature areas

## Output Format

```markdown
## PR 생성 결과

### PR 정보
- **제목**: feat(customer): 고객 로그인 기능 구현
- **브랜치**: feat/customer-login → dev
- **URL**: https://github.com/user/repo/pull/123

### 포함된 커밋
- abc1234 feat(customer): 로그인 폼 구현
- def5678 feat(customer): 로그인 API 연동

### 변경된 파일 (5개)
- `src/app/(site)/(auth)/login/page.tsx`
- `src/app/(site)/_actions/auth.ts`
- `src/app/(site)/_components/LoginForm.tsx`
- `src/app/(site)/_lib/schemas.ts`
- `src/lib/auth.ts`

### 다음 단계
1. PR 리뷰 요청
2. CI 통과 확인
3. 리뷰 피드백 반영
4. 머지
```

## Related Commands

- `/commit` - Create commit
- `/push` - Push to remote
- `/code-review` - Code review (self-check before PR)

## External Plugin Integration

PR review is delegated to the `pr-review-toolkit` plugin:
- `/review-pr` - Perform PR review
