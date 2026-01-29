# 커스터마이징 가이드

이 문서는 `etvibe-nextjs-fullstack` 플러그인을 커스터마이징하는 방법을 안내합니다.

## 목차

- [Hooks 커스터마이징](#hooks-커스터마이징)
- [Commands 추가](#commands-추가)
- [Agents 확장](#agents-확장)
- [Skills 추가](#skills-추가)
- [환경 변수](#환경-변수)

---

## Hooks 커스터마이징

### Hooks 동작 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code 실행                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                Write/Edit 도구 사용                          │
│                (파일 생성/수정)                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  PostToolUse Hook 트리거                     │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│ check-typescript  │ │ check-server-     │ │ check-prisma-     │
│      .sh          │ │   action.sh       │ │   schema.sh       │
│                   │ │                   │ │                   │
│ *.ts, *.tsx 파일  │ │ _actions/*.ts     │ │ schema.prisma     │
│ 수정 시 안내      │ │ 파일 검증         │ │ 수정 시 안내      │
└───────────────────┘ └───────────────────┘ └───────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Claude에게 결과 전달                       │
│              (다음 작업에 반영됨)                             │
└─────────────────────────────────────────────────────────────┘
```

### hooks.json 구조

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/check-typescript.sh \"$TOOL_INPUT_file_path\""
          }
        ]
      }
    ]
  }
}
```

| 필드 | 설명 |
|------|------|
| `PostToolUse` | 도구 사용 후 실행되는 Hook 타입 |
| `matcher` | 트리거할 도구 이름 (정규식) |
| `type` | Hook 종류 (`command`, `prompt` 등) |
| `command` | 실행할 스크립트 |

### 환경 변수

Hook 스크립트에서 사용 가능한 환경 변수:

| 변수 | 설명 | 예시 |
|------|------|------|
| `$TOOL_INPUT_file_path` | 수정된 파일 경로 | `/src/app/page.tsx` |
| `$TOOL_INPUT_*` | 도구에 전달된 모든 입력값 | - |
| `$CLAUDE_PLUGIN_ROOT` | 플러그인 루트 디렉토리 | `/path/to/plugin` |

### 새 Hook 스크립트 추가

1. `scripts/` 폴더에 스크립트 생성:

```bash
#!/bin/bash
# scripts/check-custom.sh
# 커스텀 검사 스크립트

FILE="$1"

if [[ "$FILE" =~ \.custom$ ]]; then
  echo "커스텀 파일이 수정되었습니다: $FILE"
  # 검사 로직
fi
```

2. 실행 권한 부여:

```bash
chmod +x scripts/check-custom.sh
```

3. `hooks/hooks.json`에 추가:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          // 기존 훅들...
          {
            "type": "command",
            "command": "./scripts/check-custom.sh \"$TOOL_INPUT_file_path\""
          }
        ]
      }
    ]
  }
}
```

---

## Commands 추가

### Commands 파일 구조

```
commands/
├── code-review.md      # /enf:code-review
├── design-feature.md   # /enf:design-feature
└── my-command.md       # /enf:my-command (새로 추가)
```

### 새 Command 생성

`commands/my-command.md` 파일 생성:

```markdown
---
name: my-command
description: 내 커스텀 명령어
---

# 내 커스텀 명령어

## 목적
이 명령어는 [목적]을 수행합니다.

## 실행 절차

1. [첫 번째 단계]
2. [두 번째 단계]
3. [세 번째 단계]

## 예시

\`\`\`bash
/enf:my-command <인자>
\`\`\`
```

### Command 네임스페이스

- 모든 Commands는 `/enf:` 접두사 사용
- 파일명이 명령어 이름이 됨 (`my-command.md` → `/enf:my-command`)

---

## Agents 확장

### Agents 파일 구조

```
agents/
├── dev-assistant.md        # 개발 지원
├── architecture-expert.md  # 설계 전문가
├── performance-expert.md   # 성능 전문가
├── docs-writer.md          # 문서 작성자
└── my-agent.md             # (새로 추가)
```

### 새 Agent 생성

`agents/my-agent.md` 파일 생성:

```markdown
---
name: my-agent
description: 내 커스텀 에이전트
mcp_servers:
  - context7
---

# 내 커스텀 에이전트

## 역할
[에이전트의 역할 설명]

## 전문 분야
- [분야 1]
- [분야 2]

## 작업 방식
1. [첫 번째 작업 방식]
2. [두 번째 작업 방식]

## 사용하는 MCP 서버
- **context7**: 문서 검색
```

### Agent 설정 옵션

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | ✅ | 에이전트 이름 (고유) |
| `description` | ✅ | 짧은 설명 |
| `mcp_servers` | - | 사용할 MCP 서버 목록 |

---

## Skills 추가

### Skills 파일 구조

```
skills/
├── coding-conventions.md
├── better-auth.md
├── prisma-7.md
├── tailwind-v4-shadcn.md
└── my-skill.md  # (새로 추가)
```

### 새 Skill 생성

`skills/my-skill.md` 파일 생성:

```markdown
---
name: my-skill
description: 내 커스텀 스킬
triggers:
  - "my-skill 관련"
  - "특정 패턴"
---

# 내 커스텀 스킬

## 개요
이 스킬은 [목적]을 위한 지식을 제공합니다.

## 핵심 패턴

### 패턴 1: 기본 사용법

\`\`\`typescript
// 코드 예시
\`\`\`

### 패턴 2: 고급 사용법

\`\`\`typescript
// 코드 예시
\`\`\`

## 주의사항
- [주의사항 1]
- [주의사항 2]
```

### Skill 자동 활성화

`triggers` 필드에 지정된 키워드가 대화에 포함되면 해당 Skill이 자동으로 활성화됩니다.

---

## 환경 변수

### Hook에서 사용 가능한 변수

| 변수 | 설명 |
|------|------|
| `$TOOL_INPUT_file_path` | Write/Edit 도구의 대상 파일 경로 |
| `$TOOL_INPUT_content` | Write 도구의 파일 내용 |
| `$TOOL_INPUT_old_string` | Edit 도구의 교체 대상 문자열 |
| `$TOOL_INPUT_new_string` | Edit 도구의 새 문자열 |
| `$CLAUDE_PLUGIN_ROOT` | 플러그인 루트 디렉토리 경로 |

### 스크립트에서 활용

```bash
#!/bin/bash

FILE="$TOOL_INPUT_file_path"
PLUGIN_DIR="$CLAUDE_PLUGIN_ROOT"

# 플러그인 설정 파일 읽기
CONFIG="$PLUGIN_DIR/.claude-plugin/plugin.json"

# 파일 확장자 추출
EXT="${FILE##*.}"
```

---

## 플러그인 검증

커스터마이징 후 플러그인이 정상 동작하는지 확인:

```bash
# 로컬 플러그인으로 Claude 실행
claude --plugin-dir ./etvibe-nextjs-fullstack

# 에이전트 목록 확인
/agents

# 명령어 테스트
/enf:init

# MCP 서버 상태 확인
/mcp
```

---

## 다음 단계

- [개발 가이드](./DEVELOPMENT.md) - 로컬 테스트 및 디버깅
- [기여 가이드](./CONTRIBUTING.md) - PR 프로세스 및 코드 리뷰
