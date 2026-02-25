---
description: Auto-update CHANGELOG.md - commit-based change history generation
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

# /update-changelog Command

Updates CHANGELOG.md based on the Git commit history.

## Usage

```
/update-changelog                       # 마지막 태그 이후 변경사항
/update-changelog --since v1.0.0        # 특정 태그 이후
/update-changelog --version 1.1.0       # 버전 명시
```

## CHANGELOG Format

Follows the [Keep a Changelog](https://keepachangelog.com/) format.

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- 새로운 기능

### Changed
- 기존 기능 변경

### Deprecated
- 곧 제거될 기능

### Removed
- 제거된 기능

### Fixed
- 버그 수정

### Security
- 보안 관련 수정

## [1.0.0] - 2024-01-15

### Added
- 초기 릴리스
- 고객 관리 기능
- 캠페인 관리 기능
```

## Commit Type Mapping

| Conventional Commit | CHANGELOG Section |
| ------------------- | -------------- |
| feat | Added |
| fix | Fixed |
| docs | Changed |
| style | Changed |
| refactor | Changed |
| perf | Changed |
| test | (excluded) |
| chore | (excluded) |
| security | Security |
| deprecate | Deprecated |
| remove | Removed |

## Automation Process

### 1. Collect Commits

```bash
# 마지막 태그 이후 커밋
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# 또는 특정 태그 이후
git log v1.0.0..HEAD --oneline
```

### 2. Classify Commits

```
feat(customer): 고객 검색 기능 추가    → Added
fix(auth): 로그인 오류 수정             → Fixed
refactor(campaign): 테이블 컴포넌트 분리 → Changed
```

### 3. Update CHANGELOG

Add new section at the top of the existing CHANGELOG.md

## Output Example

```markdown
## [1.1.0] - 2024-02-01

### Added
- 고객 검색 기능 추가 (#123)
- 인플루언서 필터 기능 구현 (#125)

### Changed
- 캠페인 테이블 컴포넌트 분리
- 대시보드 레이아웃 개선

### Fixed
- 로그인 세션 만료 오류 수정 (#120)
- 이메일 유효성 검사 버그 수정 (#122)
```

## Manual Editing Guide

After auto-generation, review and edit the following:

1. **User-friendly descriptions**: Replace technical jargon with plain language
2. **Remove duplicates**: Consolidate related commits
3. **Issue links**: Add PR/issue numbers
4. **Breaking Changes**: Highlight separately

## Breaking Changes Notation

```markdown
## [2.0.0] - 2024-03-01

### ⚠️ Breaking Changes

- `CustomerTable` props 변경: `data` → `customers`
- 최소 Node.js 버전 18.0.0 이상 필요

### Added
...
```

## Related Agents

This command is based on the `docs-writer` agent's documentation writing principles.

## Related Commands

- `/commit` - Create commit
- `/pr` - Create PR (including CHANGELOG)
