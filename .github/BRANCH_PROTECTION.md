# GitHub 브랜치 보호 설정 가이드

이 문서는 `etvibe-nextjs-fullstack` 저장소의 브랜치 보호 규칙 설정 방법을 안내합니다.

## 브랜치 전략

| 브랜치 | 용도 | 보호 수준 |
|--------|------|----------|
| `main` | 프로덕션/릴리스 | 보호됨 - PR 필수, 소유자 승인 필수 |
| `dev` | 개발/테스트 | 일반 - 직접 푸시 가능 |
| `feature/*` | 기능 개발 | 일반 - 직접 푸시 가능 |

### 워크플로우

```
feature/* → dev → main (PR 필수)
     │       │
     └───────┴── 개발자 직접 푸시 가능

main ← dev (PR 필수, 소유자 승인)
```

---

## GitHub UI에서 설정하기

### Step 1: Branch Protection Rules 페이지 접근

1. Repository 페이지에서 **Settings** 탭 클릭
2. 왼쪽 메뉴에서 **Branches** 클릭
3. **Add branch protection rule** 버튼 클릭

### Step 2: main 브랜치 보호 규칙 설정

**Branch name pattern**: `main`

다음 항목들을 체크하세요:

| 설정 | 체크 | 설명 |
|------|:----:|------|
| **Require a pull request before merging** | ✅ | 직접 푸시 금지, PR 필수 |
| └ Require approvals | ✅ | 최소 1명 승인 필요 |
| └ Required number of approvals | 1 | 승인 필요 인원 수 |
| └ Dismiss stale pull request approvals when new commits are pushed | ✅ | 새 커밋 시 기존 승인 무효화 |
| └ Require review from Code Owners | ✅ | CODEOWNERS 기반 검토 필수 |
| **Do not allow bypassing the above settings** | ✅ | 관리자도 규칙 준수 |

### Step 3: 저장

**Create** 또는 **Save changes** 버튼 클릭

---

## gh CLI로 설정하기 (선택적)

GitHub CLI가 설치되어 있다면 명령어로 설정할 수 있습니다:

```bash
gh api repos/lemon-etvibe/etvibe-nextjs-fullstack/branches/main/protection \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"require_code_owner_reviews":true,"dismiss_stale_reviews":true}' \
  --field enforce_admins=true \
  --field required_status_checks=null \
  --field restrictions=null
```

---

## 설정 확인

### 브랜치 보호 확인

```bash
# 보호 규칙 조회
gh api repos/lemon-etvibe/etvibe-nextjs-fullstack/branches/main/protection

# main에 직접 push 시도 → 거부되어야 함
git push origin main  # → 에러 발생해야 정상
```

### CODEOWNERS 확인

PR 생성 시 자동으로 `@lemon-etvibe`가 리뷰어로 지정되는지 확인

---

## 주의사항

1. **개인 저장소 제한**: 무료 플랜에서는 일부 브랜치 보호 기능이 제한될 수 있습니다
2. **팀 설정**: 팀원이 있는 경우 CODEOWNERS에 팀원도 추가 가능
3. **긴급 상황**: 긴급 수정이 필요한 경우 일시적으로 규칙을 비활성화할 수 있음 (권장하지 않음)

---

## 참고 자료

- [GitHub CODEOWNERS 문서](https://docs.github.com/articles/about-code-owners)
- [GitHub Branch Protection 문서](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)
- [gh CLI 설치](https://cli.github.com/)
