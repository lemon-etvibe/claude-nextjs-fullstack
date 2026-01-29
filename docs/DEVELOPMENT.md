# 개발 가이드

이 문서는 `etvibe-nextjs-fullstack` 플러그인의 로컬 개발, 테스트, 디버깅 방법을 안내합니다.

## 목차

- [로컬 테스트](#로컬-테스트)
- [디버깅](#디버깅)
- [버전 관리](#버전-관리)
- [배포 프로세스](#배포-프로세스)

---

## 로컬 테스트

### 플러그인 디렉토리로 실행

```bash
# 레포지토리 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git
cd etvibe-nextjs-fullstack

# 로컬 플러그인으로 Claude 실행
claude --plugin-dir .
```

### 플러그인 구성 요소 확인

```bash
# Claude 실행 후

# 에이전트 목록 확인
/agents

# MCP 서버 상태 확인
/mcp

# 초기화 명령어로 전체 확인
/enf:init
```

### 개별 구성 요소 테스트

#### Commands 테스트

```bash
# 코드 리뷰 테스트
/enf:code-review src/app/page.tsx

# 설계 테스트
/enf:design-feature "테스트 기능"

# 스키마 설계 테스트
/enf:schema-design "User-Post 관계"
```

#### Hooks 테스트

```bash
# TypeScript 파일 수정 시 Hook 동작 확인
# Claude에게 .ts 파일 생성/수정 요청

# Server Action 파일 수정 시 Hook 동작 확인
# _actions/*.ts 파일 생성/수정 요청

# Prisma 스키마 수정 시 Hook 동작 확인
# schema.prisma 파일 수정 요청
```

#### Agents 테스트

```bash
# dev-assistant 에이전트 호출
"dev-assistant 에이전트로 이 코드를 리뷰해줘"

# architecture-expert 에이전트 호출
"architecture-expert 에이전트로 이 설계를 검토해줘"
```

---

## 디버깅

### Claude 디버그 모드

```bash
# 디버그 로그 활성화
claude --debug

# 또는 상세 로그
claude --debug --verbose
```

### Hook 스크립트 디버깅

스크립트에 디버그 출력 추가:

```bash
#!/bin/bash
# scripts/check-typescript.sh

# 디버그 모드
set -x  # 실행되는 모든 명령어 출력

FILE="$1"
echo "[DEBUG] File: $FILE"
echo "[DEBUG] CLAUDE_PLUGIN_ROOT: $CLAUDE_PLUGIN_ROOT"

# ... 나머지 로직
```

### 스크립트 직접 실행

```bash
# Hook 스크립트 직접 테스트
./scripts/check-typescript.sh /path/to/test.ts

# Server Action 검사 테스트
./scripts/check-server-action.sh /path/to/_actions/test.ts

# Prisma 스키마 검사 테스트
./scripts/check-prisma-schema.sh /path/to/schema.prisma
```

### MCP 서버 디버깅

```bash
# MCP 서버 상태 확인
/mcp

# 특정 MCP 서버 재연결
# (Claude 재시작 필요)
```

### 일반적인 문제 해결

| 문제 | 해결 방법 |
|------|----------|
| Hook이 실행되지 않음 | 스크립트 실행 권한 확인 (`chmod +x`) |
| 에이전트가 인식되지 않음 | `agents/` 폴더 내 마크다운 형식 확인 |
| MCP 연결 실패 | `.mcp.json` 설정 및 npx 명령어 확인 |
| Command를 찾을 수 없음 | 파일명과 frontmatter `name` 일치 확인 |

---

## 버전 관리

### 버전 번호 규칙

[Semantic Versioning](https://semver.org/) 사용:

```
MAJOR.MINOR.PATCH

예: 1.2.3
    │ │ └── PATCH: 버그 수정, 하위 호환
    │ └──── MINOR: 새 기능 추가, 하위 호환
    └────── MAJOR: 호환성 깨지는 변경
```

### 버전 업데이트

1. `plugin.json`의 버전 업데이트:

```json
{
  "name": "etvibe-nextjs-fullstack",
  "version": "1.2.3"
}
```

2. CHANGELOG 업데이트:

```bash
/enf:update-changelog
```

3. 커밋 및 태그:

```bash
git add .
git commit -m "chore: bump version to 1.2.3"
git tag v1.2.3
git push origin main --tags
```

### 버전 업그레이드 절차

기존 사용자의 플러그인 업그레이드:

```bash
# 플러그인 업데이트
claude plugin update etvibe-nextjs-fullstack

# 또는 재설치
claude plugin uninstall etvibe-nextjs-fullstack
claude plugin install etvibe-nextjs-fullstack
```

---

## 배포 프로세스

### 릴리스 체크리스트

- [ ] 모든 테스트 통과
- [ ] 버전 번호 업데이트
- [ ] CHANGELOG 업데이트
- [ ] README 업데이트 (필요시)
- [ ] PR 생성 및 승인
- [ ] main 브랜치 머지
- [ ] 릴리스 태그 생성

### 릴리스 생성

1. **dev → main PR 생성**:

```bash
gh pr create \
  --base main \
  --head dev \
  --title "Release v1.2.3" \
  --body "## Changes
- 변경사항 1
- 변경사항 2
"
```

2. **PR 승인 및 머지** (CODEOWNERS 승인 필요)

3. **릴리스 태그 생성**:

```bash
git checkout main
git pull origin main
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

4. **GitHub Release 생성**:

```bash
gh release create v1.2.3 \
  --title "v1.2.3" \
  --notes "## What's Changed
- 변경사항 1
- 변경사항 2
"
```

### 롤백

문제 발생 시 이전 버전으로 롤백:

```bash
# 이전 커밋으로 되돌리기
git revert HEAD
git push origin main

# 또는 이전 버전 태그로 되돌리기
git checkout v1.2.2
```

---

## 개발 환경 설정

### 권장 도구

| 도구 | 용도 |
|------|------|
| VSCode | 편집기 |
| gh CLI | GitHub 작업 |
| shellcheck | Bash 스크립트 린트 |

### VSCode 확장

```json
{
  "recommendations": [
    "timonwong.shellcheck",
    "foxundermoon.shell-format",
    "yzhang.markdown-all-in-one"
  ]
}
```

### 스크립트 린트

```bash
# shellcheck 설치 (macOS)
brew install shellcheck

# 스크립트 검사
shellcheck scripts/*.sh
```

---

## 다음 단계

- [커스터마이징 가이드](./CUSTOMIZATION.md) - Hooks, Commands, Agents 확장
- [기여 가이드](./CONTRIBUTING.md) - PR 프로세스 및 코드 리뷰
