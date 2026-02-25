---
description: Git remote push - safe push workflow
allowed-tools:
  - Bash
---

# /push Command

Pushes the current branch to the remote repository.

## Usage

```
/push                   # 현재 브랜치 푸시
/push --force           # 강제 푸시 (주의!)
/push -u                # upstream 설정 후 푸시
```

## Workflow

### 1. Pre-checks

```bash
# 현재 브랜치 확인
BRANCH=$(git branch --show-current)

# 보호 브랜치 체크
if [[ "$BRANCH" == "main" || "$BRANCH" == "dev" ]]; then
  echo "⚠️  경고: '$BRANCH'는 보호된 브랜치입니다."
  echo "직접 푸시가 금지되어 있습니다. PR을 통해 변경하세요."
  echo ""
  echo "권장 워크플로우:"
  echo "  1. git checkout -b feat/your-feature"
  echo "  2. [변경 작업]"
  echo "  3. /commit → /push → /pr"
  exit 1
fi

# 커밋되지 않은 변경사항 확인
git status

# 원격과의 차이 확인
git log origin/$BRANCH..HEAD --oneline 2>/dev/null || echo "(새 브랜치)"
```

### 2. Execute Push

#### First Push (set upstream)

```bash
git push -u origin $(git branch --show-current)
```

#### Subsequent Pushes

```bash
git push
```

### 3. Post-push Verification

```bash
git log origin/$(git branch --show-current) --oneline -3
```

## Safety Checklist

### Pre-push Verification

- [ ] Is it the correct branch?
- [ ] Are there no uncommitted changes?
- [ ] Are the local commits intended?
- [ ] Is this not main/dev? (protected branches)

### Protected Branch Policy

| Branch | Direct Push | PR Required | Description |
|--------|:---------:|:-------:|------|
| `main` | ❌ | ✅ | Production release |
| `dev` | ❌ | ✅ | Development integration branch |
| `feat/*`, `fix/*`, etc. | ✅ | - | Feature branches |

### Force Push Warning

```
⚠️  경고: --force 옵션은 원격 히스토리를 덮어씁니다!

다음 경우에만 사용하세요:
- 개인 브랜치의 rebase 후
- PR 리뷰 피드백 반영 후 squash
- 실수로 푸시한 민감 정보 제거

절대 금지:
- main/master 브랜치
- 다른 팀원이 작업 중인 브랜치
```

## Common Troubleshooting

### 1. Remote Has Changes

```bash
# 먼저 pull
git pull --rebase origin $(git branch --show-current)

# 그 다음 push
git push
```

### 2. Upstream Not Set

```bash
git push -u origin $(git branch --show-current)
```

### 3. Permission Error

```bash
# SSH 키 확인
ssh -T git@github.com

# 또는 HTTPS 토큰 확인
```

## Output Format

```markdown
## 푸시 결과

### 사전 체크
- **현재 브랜치**: feat/customer-login
- **커밋되지 않은 변경**: 없음
- **푸시할 커밋**: 3개

### 푸시할 커밋 목록
```
abc1234 feat(customer): 로그인 폼 구현
def5678 feat(customer): 로그인 API 연동
ghi9012 test(customer): 로그인 테스트 추가
```

### 실행 결과
```bash
git push -u origin feat/customer-login
```

- **상태**: 성공
- **원격 URL**: https://github.com/user/repo

### 다음 단계
- `/pr` - Pull Request 생성
```

## Related Commands

- `/commit` - Create commit
- `/pr` - Create PR
