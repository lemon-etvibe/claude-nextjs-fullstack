# 설치 가이드

etvibe-nextjs-fullstack (enf) 플러그인 상세 설치 가이드입니다.

---

## 빠른 설치 (셋업 스크립트)

### Windows (PowerShell)

```powershell
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git C:\plugins\enf

# 2. 셋업 스크립트 실행
cd C:\plugins\enf
.\scripts\setup.ps1

# 3. 프로젝트에서 사용
cd C:\projects\your-project
claude
```

### macOS/Linux

```bash
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git ~/plugins/enf

# 2. 셋업 스크립트 실행
cd ~/plugins/enf
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. 프로젝트에서 사용
cd ~/projects/your-project
claude
```

---

## 수동 설치

셋업 스크립트 없이 수동으로 설치하는 방법입니다.

### 1. 외부 마켓플레이스 등록

```bash
claude plugin marketplace add https://github.com/wshobson/agents
claude plugin marketplace update
```

### 2. 외부 플러그인 설치

#### Anthropic 공식 플러그인

```bash
claude plugin install playwright@claude-plugins-official
claude plugin install pr-review-toolkit@claude-plugins-official
claude plugin install commit-commands@claude-plugins-official
claude plugin install feature-dev@claude-plugins-official
claude plugin install security-guidance@claude-plugins-official
claude plugin install context7@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
claude plugin install code-review@claude-plugins-official
```

#### 커뮤니티 플러그인 (wshobson/agents)

```bash
claude plugin install javascript-typescript@claude-code-workflows
claude plugin install database-design@claude-code-workflows
```

#### 선택 플러그인 (React 최적화)

```bash
# Vercel Labs의 React 스킬 (별도 설치 방식)
npx @anthropic-ai/claude-code add-skill react-best-practices
```

### 3. 로컬 마켓플레이스 등록 및 enf 플러그인 설치

```bash
# 플러그인 경로로 이동
cd ~/plugins/enf  # 또는 C:\plugins\enf

# 로컬 마켓플레이스 등록
claude plugin marketplace add file://$(pwd)

# enf 플러그인 설치 (--scope local로 프로젝트 독립 설치)
claude plugin install enf@enf-local --scope local
```

---

## 외부 플러그인 상세

### Anthropic 공식 플러그인

| 플러그인 | 용도 | 주요 기능 |
|---------|------|----------|
| playwright | E2E 테스트 | Playwright 테스트 작성/실행 |
| pr-review-toolkit | PR 리뷰 | `/review-pr` 명령어, 6가지 관점 리뷰 |
| commit-commands | 커밋 생성 | `/commit` 명령어, 변경사항 분석 |
| feature-dev | 기능 개발 | 기능 개발 워크플로우 지원 |
| security-guidance | 보안 검사 | OWASP Top 10 취약점 검사 |
| context7 | 문서 조회 | 라이브러리 최신 문서 조회 |
| frontend-design | UI 디자인 | 고품질 프론트엔드 UI 디자인 |
| code-review | 코드 리뷰 | 자동 코드 리뷰 |

### 커뮤니티 플러그인 (wshobson/agents)

| 플러그인 | 용도 |
|---------|------|
| javascript-typescript | JS/TS 전문가 에이전트 |
| database-design | 스키마 설계 에이전트 |

### 선택 플러그인 (수동 설치)

```bash
# React 최적화 패턴 (Vercel Labs - 별도 설치 방식)
npx @anthropic-ai/claude-code add-skill react-best-practices
```

---

## 프로젝트 설정 파일

### 플러그인에 포함된 설정

| 파일 | 용도 |
|------|------|
| `.mcp.json` | MCP 서버 설정 (context7, next-devtools, prisma-local) |
| `.claude-plugin/plugin.json` | 플러그인 매니페스트 |
| `.claude-plugin/marketplace.json` | 로컬 마켓플레이스 정의 |

### 프로젝트 범위 설정 (옵셔널)

대상 프로젝트에 `.claude/settings.json` 생성:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx prisma *)"
    ]
  }
}
```

### 개인 설정 (gitignore)

대상 프로젝트에 `.claude/settings.local.json` 생성:

```json
{
  "preferences": {
    "language": "ko"
  }
}
```

---

## 글로벌 설정 (옵셔널)

모든 프로젝트에 적용되는 글로벌 설정:

### Windows

```
%USERPROFILE%\.claude\settings.json
```

### macOS/Linux

```
~/.claude/settings.json
```

### 예시

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)"
    ]
  },
  "preferences": {
    "language": "ko"
  }
}
```

---

## 플러그인 업데이트

```bash
# Windows
cd C:\plugins\enf
git pull origin main
claude plugin install enf@enf-local --scope local

# macOS/Linux
cd ~/plugins/enf
git pull origin main
claude plugin install enf@enf-local --scope local
```

외부 플러그인도 업데이트하려면 셋업 스크립트를 다시 실행:

```bash
# Windows
.\scripts\setup.ps1

# macOS/Linux
./scripts/setup.sh
```

---

## 문제 해결

### MCP 연결 안 됨

```bash
# MCP 상태 확인
/mcp

# Claude Code 재시작
claude
```

MCP 서버가 표시되지 않으면:
- `.mcp.json` 파일이 플러그인 루트에 있는지 확인
- 플러그인이 설치되어 있는지 확인: `claude plugin list`

### 에이전트 인식 안 됨

```bash
# 에이전트 목록 확인
/agents

# 플러그인 설치 확인
claude plugin list

# enf 플러그인 재설치
claude plugin install enf@enf-local --scope local
```

에이전트가 표시되지 않으면:
- enf 플러그인이 설치되어 있는지 확인
- 로컬 마켓플레이스가 등록되어 있는지 확인: `claude plugin marketplace list`

### 플러그인 로드 안 됨

```bash
# 매니페스트 파일 검증
claude plugin validate ~/plugins/enf  # 또는 C:\plugins\enf

# 매니페스트 파일 확인 (macOS/Linux)
cat ~/plugins/enf/.claude-plugin/plugin.json

# 매니페스트 파일 확인 (Windows)
type C:\plugins\enf\.claude-plugin\plugin.json
```

**검증 실패 시**: `plugin.json`에 지원되지 않는 필드가 있을 수 있습니다.
공식 스키마에서 지원하는 필드:
- `name`, `version`, `description`, `author`, `homepage`, `repository`, `license`, `keywords`
- `commands`, `agents`, `skills`, `hooks`, `mcpServers`, `outputStyles`, `lspServers`

문제가 지속되면:
- Claude Code 버전 확인: `claude --version`
- 플러그인 재설치: `claude plugin install enf@enf-local --scope local`

### 외부 플러그인 설치 실패

```bash
# 마켓플레이스 목록 확인
claude plugin marketplace list

# 마켓플레이스 업데이트
claude plugin marketplace update

# 플러그인 재설치
claude plugin uninstall playwright
claude plugin install playwright@claude-plugins-official
```

네트워크 오류 시:
- GitHub 접근 가능 여부 확인
- 프록시 설정 확인

### 플러그인 완전 재설치

문제가 지속되면 플러그인을 완전히 제거하고 다시 설치:

```bash
# 플러그인 제거
claude plugin uninstall enf

# 로컬 마켓플레이스 확인
claude plugin marketplace list

# 재설치
claude plugin install enf@enf-local --scope local
```

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [README](../README.md) | 빠른 시작 가이드 |
| [커스터마이징 가이드](./CUSTOMIZATION.md) | Hooks, Commands, Agents, Skills 확장 |
| [개발 가이드](./DEVELOPMENT.md) | 로컬 테스트, 디버깅, 배포 |
| [기여 가이드](./CONTRIBUTING.md) | 브랜치 규칙, PR 프로세스 |
