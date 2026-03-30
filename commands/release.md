---
description: Automated release workflow - version bump, CHANGELOG, PR creation in one step
allowed-tools:
  - Bash
  - Read
  - Edit
  - Glob
  - Grep
---

# /release Command

Automates the full release process: version detection, plugin.json update, CHANGELOG cleanup, commit, push, and release PR creation.

> Solves the manual release problems encountered in v1.1.1: forgotten version bump, CHANGELOG duplication, multi-step manual process.

## Usage

```
/enf:release                     # 버전 자동 결정 (CHANGELOG 기반)
/enf:release --version 1.2.0     # 버전 수동 지정
```

## Workflow

### 1. Pre-checks

```bash
# dev 브랜치 확인
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "dev" ]]; then
  echo "❌ 릴리스는 dev 브랜치에서만 가능합니다."
  exit 1
fi

# 최신 상태 확인
git fetch origin
if [[ $(git rev-list HEAD..origin/dev --count) -gt 0 ]]; then
  echo "❌ dev 브랜치가 최신이 아닙니다. git pull 먼저 실행하세요."
  exit 1
fi

# 커밋되지 않은 변경사항 확인
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️ 커밋되지 않은 변경사항이 있습니다. 먼저 커밋하세요."
  exit 1
fi
```

### 2. Version Detection

```bash
# --version 플래그가 없으면 CHANGELOG에서 결정
# [Unreleased] 섹션의 변경 유형에 따라:
#   - feat → MINOR bump
#   - fix/docs/refactor → PATCH bump
#   - BREAKING → MAJOR bump
```

If version cannot be determined automatically, ask the user.

### 3. CHANGELOG Cleanup

Before release, verify:
- `[Unreleased]` section has content (abort if empty)
- No duplicate version sections exist
- Previous version sections from main merge are correctly placed

### 4. Version Bump

```bash
# .claude-plugin/plugin.json 업데이트
# "version": "1.1.1" → "version": "1.2.0"
```

Read `.claude-plugin/plugin.json`, update the `version` field to the new version.

### 5. Commit & Push

```bash
git add .claude-plugin/plugin.json CHANGELOG.md
git commit -m "chore: bump plugin version to ${VERSION}"
git push origin dev
```

### 6. Release PR Creation

```bash
gh pr create \
  --base main \
  --title "release: v${VERSION}" \
  --body "## 릴리스 v${VERSION}

### CHANGELOG 미리보기

${UNRELEASED_CONTENT}

### 체크리스트

- [ ] CHANGELOG 내용 확인
- [ ] 모든 기능 테스트 완료
- [ ] 문서 업데이트 완료
- [ ] plugin.json 버전 확인: ${VERSION}

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### 7. Post-Release Reminder

```markdown
## 릴리스 결과

- **버전**: v${VERSION}
- **PR**: ${PR_URL}
- **plugin.json**: ${VERSION} ✅

### 머지 후 자동 처리
1. release.yml → CHANGELOG 확정 + 태그 생성 + GitHub Release
2. deliver.yml → 퍼블릭 레포 딜리버리

### ⚠️ 알려진 이슈
deliver.yml은 GITHUB_TOKEN으로 생성된 태그에 트리거되지 않습니다.
머지 후 딜리버리가 안 되면:
  git push origin :refs/tags/v${VERSION}
  git tag -a v${VERSION} origin/main -m "Release v${VERSION}"
  git push origin v${VERSION}
```

## Error Handling

| Error | Action |
|-------|--------|
| Not on dev branch | Abort with message |
| Uncommitted changes | Abort with message |
| Empty [Unreleased] | Ask user if intentional empty release |
| PR creation fails | Show error, provide manual gh command |
| Version conflict | Show current version, ask for new version |

## Related Commands

- `/enf:pr --release` — Release PR only (no version bump)
- `/enf:validate` — Run before release to ensure quality
- `/enf:update-changelog` — Manual CHANGELOG update
