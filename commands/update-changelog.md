---
description: CHANGELOG.md 자동 업데이트 - 커밋 기반 변경 이력 생성
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

# /update-changelog 명령어

Git 커밋 히스토리를 기반으로 CHANGELOG.md를 업데이트합니다.

## 사용법

```
/update-changelog                       # 마지막 태그 이후 변경사항
/update-changelog --since v1.0.0        # 특정 태그 이후
/update-changelog --version 1.1.0       # 버전 명시
```

## CHANGELOG 형식

[Keep a Changelog](https://keepachangelog.com/) 형식을 따릅니다.

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

## 커밋 타입 매핑

| Conventional Commit | CHANGELOG 섹션 |
| ------------------- | -------------- |
| feat | Added |
| fix | Fixed |
| docs | Changed |
| style | Changed |
| refactor | Changed |
| perf | Changed |
| test | (제외) |
| chore | (제외) |
| security | Security |
| deprecate | Deprecated |
| remove | Removed |

## 자동화 프로세스

### 1. 커밋 수집

```bash
# 마지막 태그 이후 커밋
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# 또는 특정 태그 이후
git log v1.0.0..HEAD --oneline
```

### 2. 커밋 분류

```
feat(customer): 고객 검색 기능 추가    → Added
fix(auth): 로그인 오류 수정             → Fixed
refactor(campaign): 테이블 컴포넌트 분리 → Changed
```

### 3. CHANGELOG 업데이트

기존 CHANGELOG.md 상단에 새 섹션 추가

## 출력 예시

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

## 수동 편집 가이드

자동 생성 후 다음을 검토/수정하세요:

1. **사용자 친화적 설명**: 기술적 용어를 일반 용어로
2. **중복 제거**: 관련 커밋 통합
3. **이슈 링크**: PR/이슈 번호 추가
4. **Breaking Changes**: 별도 하이라이트

## Breaking Changes 표시

```markdown
## [2.0.0] - 2024-03-01

### ⚠️ Breaking Changes

- `CustomerTable` props 변경: `data` → `customers`
- 최소 Node.js 버전 18.0.0 이상 필요

### Added
...
```

## 연계 에이전트

이 명령어는 `docs-writer` 에이전트의 문서 작성 원칙을 기반으로 합니다.

## 연계 명령어

- `/commit` - 커밋 생성
- `/pr` - PR 생성 (CHANGELOG 포함)
