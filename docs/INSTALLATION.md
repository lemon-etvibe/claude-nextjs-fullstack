# 설치 가이드

etvibe-nextjs-fullstack (enf) 플러그인 상세 설치 가이드입니다.

---

## 빠른 설치 (셋업 스크립트)

셋업 스크립트는 **플러그인 디렉토리에서 실행**하며, 설치할 프로젝트 경로를 입력받습니다.

<table>
<tr><th>macOS/Linux</th><th>Windows (PowerShell)</th></tr>
<tr>
<td>

```bash
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git ~/plugins/enf

# 2. 셋업 스크립트 실행
cd ~/plugins/enf
chmod +x scripts/setup.sh
./scripts/setup.sh ~/projects/my-app
# 또는 인터랙티브: ./scripts/setup.sh

# 3. 사용
cd ~/projects/my-app && claude
```

</td>
<td>

```powershell
# 1. 플러그인 클론
git clone https://github.com/lemon-etvibe/etvibe-nextjs-fullstack.git C:\plugins\enf

# 2. 셋업 스크립트 실행
cd C:\plugins\enf
.\scripts\setup.ps1 C:\projects\my-app

# 3. 사용
cd C:\projects\my-app; claude
```

</td>
</tr>
</table>

### 설치 확인

```bash
/agents      # 에이전트 4개 확인
/mcp         # MCP 서버 상태 확인
/enf:init    # 플러그인 가이드
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

```bash
# Anthropic 공식
claude plugin install playwright@claude-plugins-official
claude plugin install pr-review-toolkit@claude-plugins-official
claude plugin install commit-commands@claude-plugins-official
claude plugin install feature-dev@claude-plugins-official
claude plugin install security-guidance@claude-plugins-official
claude plugin install context7@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
claude plugin install code-review@claude-plugins-official

# 커뮤니티 (wshobson/agents)
claude plugin install javascript-typescript@claude-code-workflows
claude plugin install database-design@claude-code-workflows

# 선택: React 최적화 (Vercel Labs)
npx @anthropic-ai/claude-code add-skill react-best-practices
```

### 3. enf 플러그인 설치

```bash
cd ~/plugins/enf  # 또는 C:\plugins\enf
claude plugin marketplace add file://$(pwd)
claude plugin install enf@enf-local --scope local
```

---

## 외부 플러그인 목록

### Anthropic 공식

| 플러그인 | 용도 |
|---------|------|
| playwright | E2E 테스트 작성/실행 |
| pr-review-toolkit | `/review-pr` 6가지 관점 리뷰 |
| commit-commands | `/commit` 변경사항 분석 커밋 |
| feature-dev | 기능 개발 워크플로우 |
| security-guidance | OWASP Top 10 보안 검사 |
| context7 | 라이브러리 문서 조회 |
| frontend-design | 고품질 UI 디자인 |
| code-review | 자동 코드 리뷰 |

### 커뮤니티 (wshobson/agents)

| 플러그인 | 용도 |
|---------|------|
| javascript-typescript | JS/TS 전문가 에이전트 |
| database-design | 스키마 설계 에이전트 |

---

## 프로젝트 설정

### 플러그인 포함 설정

| 파일 | 용도 |
|------|------|
| `.mcp.json` | MCP 서버 설정 |
| `.claude-plugin/plugin.json` | 플러그인 매니페스트 |

### 프로젝트 범위 설정 (옵셔널)

대상 프로젝트에 `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(npx prisma *)"]
  }
}
```

### 글로벌 설정 (옵셔널)

| OS | 경로 |
|----|------|
| macOS/Linux | `~/.claude/settings.json` |
| Windows | `%USERPROFILE%\.claude\settings.json` |

---

## 플러그인 업데이트

```bash
cd ~/plugins/enf    # 또는 C:\plugins\enf
git pull origin main
./scripts/setup.sh  # 또는 .\scripts\setup.ps1
```

---

## 플러그인 삭제

enf 플러그인은 `--scope local`로 프로젝트별 설치됩니다.

```bash
# 프로젝트에서 삭제
cd ~/projects/my-app
claude plugin uninstall enf@enf-local

# 마켓플레이스 등록 해제
claude plugin marketplace remove enf-local

# 플러그인 파일 삭제
rm -rf ~/plugins/enf  # macOS/Linux
# Remove-Item -Recurse -Force C:\plugins\enf  # Windows
```

---

## 문제 해결

### MCP 연결 안 됨

```bash
/mcp                   # 상태 확인
claude                 # 재시작
claude plugin list     # 설치 확인
```

### 에이전트 인식 안 됨

```bash
/agents                                    # 목록 확인
claude plugin list                         # 설치 확인
claude plugin install enf@enf-local --scope local  # 재설치
```

### 플러그인 로드 안 됨

```bash
# 매니페스트 검증
claude plugin validate ~/plugins/enf

# 지원 필드 확인
# name, version, description, author, homepage, repository, license, keywords
# commands, agents, skills, hooks, mcpServers, outputStyles, lspServers
```

### 외부 플러그인 설치 실패

```bash
claude plugin marketplace list     # 마켓플레이스 확인
claude plugin marketplace update   # 업데이트
claude plugin uninstall playwright # 삭제 후
claude plugin install playwright@claude-plugins-official  # 재설치
```

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [README](../README.md) | 빠른 시작 |
| [CUSTOMIZATION](./CUSTOMIZATION.md) | 플러그인 확장 |
| [DEVELOPMENT](./DEVELOPMENT.md) | 로컬 개발/디버깅 |
| [CONTRIBUTING](./CONTRIBUTING.md) | 기여 가이드 |
