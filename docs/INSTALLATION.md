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

# 3. 새 PowerShell 창에서 사용
cd C:\projects\your-project
claude-enf
```

### macOS/Linux

```bash
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git ~/plugins/enf

# 2. 셋업 스크립트 실행
cd ~/plugins/enf
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. 새 터미널에서 사용
cd ~/projects/your-project
claude-enf
```

---

## 수동 설치

셋업 스크립트 없이 수동으로 설치하는 방법입니다.

### 1. 마켓플레이스 등록

```bash
claude plugin marketplace add https://github.com/vercel-labs/agent-skills
claude plugin marketplace add https://github.com/wshobson/agents
```

### 2. 외부 플러그인 설치

#### Anthropic 공식 플러그인

```bash
claude plugin install playwright@claude-plugin-directory
claude plugin install pr-review-toolkit@claude-plugin-directory
claude plugin install commit-commands@claude-plugin-directory
claude plugin install feature-dev@claude-plugin-directory
claude plugin install security-guidance@claude-plugin-directory
```

#### 커뮤니티 플러그인

```bash
claude plugin install react-best-practices@agent-skills
claude plugin install javascript-typescript@agents
claude plugin install database-design@agents
```

### 3. Shell Alias 수동 등록

#### Windows (PowerShell)

```powershell
# PowerShell 프로필 열기
notepad $PROFILE

# 다음 내용 추가
function claude-enf {
    claude --plugin-dir "C:\plugins\enf" $args
}
```

#### macOS/Linux

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
echo 'alias claude-enf="claude --plugin-dir ~/plugins/enf"' >> ~/.zshrc
source ~/.zshrc
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

### 커뮤니티 플러그인

| 출처 | 플러그인 | 용도 |
|------|---------|------|
| Vercel Labs | react-best-practices | React 최적화 패턴 (자동 적용) |
| wshobson | javascript-typescript | JS/TS 전문가 에이전트 |
| wshobson | database-design | 스키마 설계 에이전트 |

### 옵셔널 플러그인

필요시 수동 설치:

```bash
# 고품질 프론트엔드 UI 디자인 (Anthropic)
claude plugin install frontend-design@claude-plugin-directory

# 접근성/UX 감사 100+ 규칙 (Vercel Labs)
claude plugin install web-design-guidelines@agent-skills
```

---

## 프로젝트 설정 파일

### 플러그인에 포함된 설정

| 파일 | 용도 |
|------|------|
| `.mcp.json` | MCP 서버 설정 (context7, next-devtools, prisma-local) |
| `.claude-plugin/plugin.json` | 플러그인 매니페스트 |

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

# macOS/Linux
cd ~/plugins/enf
git pull origin main
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
claude-enf
```

MCP 서버가 표시되지 않으면:
- `.mcp.json` 파일이 플러그인 루트에 있는지 확인
- 플러그인 경로가 올바른지 확인

### 에이전트 인식 안 됨

```bash
# 에이전트 목록 확인
/agents

# 플러그인 경로 확인 (Windows)
dir C:\plugins\enf\agents\

# 플러그인 경로 확인 (macOS/Linux)
ls ~/plugins/enf/agents/
```

에이전트가 표시되지 않으면:
- `--plugin-dir` 경로가 정확한지 확인
- 플러그인 디렉토리 구조가 올바른지 확인

### 플러그인 로드 안 됨

```bash
# 매니페스트 파일 확인 (Windows)
type C:\plugins\enf\.claude-plugin\plugin.json

# 매니페스트 파일 확인 (macOS/Linux)
cat ~/plugins/enf/.claude-plugin/plugin.json
```

문제가 지속되면:
- 절대 경로로 실행: `claude --plugin-dir /full/path/to/enf`
- Claude Code 버전 확인: `claude --version`

### 외부 플러그인 설치 실패

```bash
# 마켓플레이스 목록 확인
claude plugin marketplace list

# 플러그인 재설치
claude plugin uninstall playwright
claude plugin install playwright@claude-plugin-directory
```

네트워크 오류 시:
- GitHub 접근 가능 여부 확인
- 프록시 설정 확인

### Shell Alias 동작 안 함

#### Windows

```powershell
# 프로필 위치 확인
echo $PROFILE

# 프로필 내용 확인
type $PROFILE

# 프로필 다시 로드
. $PROFILE
```

#### macOS/Linux

```bash
# 어떤 셸인지 확인
echo $SHELL

# 프로필 확인 (zsh)
cat ~/.zshrc | grep claude-enf

# 프로필 확인 (bash)
cat ~/.bashrc | grep claude-enf

# 다시 로드
source ~/.zshrc  # 또는 source ~/.bashrc
```

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [README](../README.md) | 빠른 시작 가이드 |
| [커스터마이징 가이드](./CUSTOMIZATION.md) | Hooks, Commands, Agents, Skills 확장 |
| [개발 가이드](./DEVELOPMENT.md) | 로컬 테스트, 디버깅, 배포 |
| [기여 가이드](./CONTRIBUTING.md) | 브랜치 규칙, PR 프로세스 |
