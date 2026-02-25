# 플러그인 확장 가이드

etvibe-nextjs-fullstack (enf) 플러그인을 확장하고 커스터마이징하는 완전 가이드입니다.

---

## 목차

- [확장 개요](#확장-개요)
- [Agent 추가](#agent-추가)
- [Command 추가](#command-추가)
- [Skill 추가](#skill-추가)
- [Hook 추가](#hook-추가)
- [환경 변수](#환경-변수)
- [검증 및 테스트](#검증-및-테스트)

---

## 확장 개요

### 플러그인 구조

```
etvibe-nextjs-fullstack/
├── agents/                 # AI 에이전트 정의
│   ├── dev-assistant.md
│   ├── architecture-expert.md
│   ├── performance-expert.md
│   └── docs-writer.md
├── commands/               # 슬래시 커맨드
│   ├── code-review.md
│   ├── commit.md
│   └── ...
├── skills/                 # 지식 베이스
│   ├── coding-conventions.md
│   ├── better-auth.md
│   └── ...
├── scripts/                # 셋업 및 Hook 스크립트
│   ├── setup.sh
│   ├── check-typescript.sh
│   ├── check-server-action.sh
│   └── check-prisma-schema.sh
└── .claude-plugin/         # 플러그인 매니페스트
    └── plugin.json         # (hooks 섹션 포함)
```

### 확장 포인트

| 확장 | 용도 | 파일 위치 |
|------|------|-----------|
| **Agent** | 역할별 AI 에이전트 | `agents/*.md` |
| **Command** | `/enf:명령어` 슬래시 커맨드 | `commands/*.md` |
| **Skill** | 자동 활성화 지식 베이스 | `skills/*.md` |
| **Hook** | 파일 수정 시 자동 검증 | `.claude-plugin/plugin.json` |

---

## Agent 추가

### 파일 생성

`agents/my-agent.md` 파일 생성:

```markdown
---
name: my-agent
description: 에이전트 한 줄 설명
tools:
  - Read
  - Edit
  - Grep
  - Glob
  - mcp__context7__query-docs
---

# 에이전트 제목

## 역할
- 역할 1: 구체적인 책임
- 역할 2: 구체적인 책임

## 전문 분야
- 기술 스택 정보
- 특화된 영역

## 작업 지침
1. 첫 번째 단계
2. 두 번째 단계
3. 세 번째 단계

## 주의사항
- 하지 말아야 할 것
- 제한 사항
```

### Frontmatter 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | O | 에이전트 고유 이름 (영문, 하이픈 허용) |
| `description` | O | 짧은 설명 (50자 이내) |
| `tools` | - | 사용할 도구 목록 |

### 사용 가능한 Tools

| Tool | 용도 |
|------|------|
| `Read` | 파일 읽기 |
| `Edit` | 파일 수정 |
| `Write` | 파일 생성 |
| `Grep` | 패턴 검색 |
| `Glob` | 파일 찾기 |
| `Bash` | 명령어 실행 |
| `mcp__context7__query-docs` | 라이브러리 문서 조회 |
| `mcp__next-devtools__*` | Next.js 개발 서버 연동 |

### 예시: 테스트 전문가 에이전트

```markdown
---
name: test-expert
description: 테스트 작성 및 커버리지 분석 전문가
tools:
  - Read
  - Edit
  - Bash
  - Grep
---

# 테스트 전문가

## 역할
- 단위 테스트 작성
- 통합 테스트 설계
- 테스트 커버리지 분석

## 전문 분야
- Vitest 테스트 프레임워크
- React Testing Library
- MSW 목 서버

## 작업 지침
1. 테스트 대상 코드 분석
2. 테스트 케이스 설계
3. 테스트 코드 작성
4. 커버리지 확인
```

---

## Command 추가

### 파일 생성

`commands/my-command.md` 파일 생성:

```markdown
---
name: my-command
description: 명령어 한 줄 설명
---

# 명령어 제목

## 목적
이 명령어의 목적을 설명합니다.

## 사용법

\`\`\`bash
/enf:my-command [옵션] <인자>
\`\`\`

## 인자

| 인자 | 필수 | 설명 |
|------|:----:|------|
| `인자명` | O | 설명 |
| `[옵션]` | - | 설명 |

## 실행 절차

1. 첫 번째 단계
2. 두 번째 단계
3. 세 번째 단계

## 예시

\`\`\`bash
/enf:my-command "예시 인자"
\`\`\`

## 출력 형식

예상되는 출력 형식을 설명합니다.
```

### 네이밍 규칙

- 파일명이 명령어 이름이 됨: `my-command.md` → `/enf:my-command`
- 영문 소문자와 하이픈만 사용
- 동사로 시작 권장: `check-`, `generate-`, `update-`

### 예시: 의존성 검사 커맨드

```markdown
---
name: check-deps
description: 프로젝트 의존성 버전 검사
---

# 의존성 검사

## 목적
package.json의 의존성 버전을 검사하고 업데이트를 제안합니다.

## 사용법

\`\`\`bash
/enf:check-deps [--outdated]
\`\`\`

## 실행 절차

1. package.json 읽기
2. 최신 버전 확인
3. 업데이트 제안 출력
```

---

## Skill 추가

### 파일 생성

`skills/my-skill.md` 파일 생성:

```markdown
---
name: my-skill
description: 스킬 한 줄 설명
triggers:
  - "키워드1"
  - "키워드2"
---

# 스킬 제목

## 개요
이 스킬이 제공하는 지식을 설명합니다.

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
- 주의사항 1
- 주의사항 2

## 관련 문서
- [공식 문서](https://...)
```

### Frontmatter 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | O | 스킬 고유 이름 |
| `description` | O | 짧은 설명 |
| `triggers` | - | 자동 활성화 키워드 목록 |

### 자동 활성화

`triggers`에 지정된 키워드가 대화에 포함되면 해당 스킬이 자동으로 컨텍스트에 추가됩니다.

```yaml
triggers:
  - "zustand"
  - "상태 관리"
  - "전역 상태"
```

### 예시: Zustand 스킬

```markdown
---
name: zustand
description: Zustand 상태 관리 라이브러리 패턴
triggers:
  - "zustand"
  - "상태 관리"
  - "전역 상태"
---

# Zustand 상태 관리

## 개요
Zustand는 간단하고 빠른 React 상태 관리 라이브러리입니다.

## 핵심 패턴

### Store 생성

\`\`\`typescript
import { create } from 'zustand'

interface CounterStore {
  count: number
  increment: () => void
  decrement: () => void
}

export const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}))
\`\`\`
```

---

## Hook 추가

### hooks.json에 정의

`hooks/hooks.json` 파일에 hooks를 정의합니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/post-write-check.sh \"$TOOL_INPUT_file_path\""
          }
        ]
      }
    ]
  }
}
```

> **중요**: 스크립트 경로는 반드시 `${CLAUDE_PLUGIN_ROOT}`를 사용해야 다른 프로젝트에서 정상 동작합니다.
> **참고**: 기존 3개 스크립트(check-typescript, check-server-action, check-prisma-schema)는 `post-write-check.sh`로 통합되었습니다.

### 대안: plugin.json 인라인

hooks가 간단한 경우 `.claude-plugin/plugin.json`에 직접 정의할 수도 있습니다:

```json
{
  "name": "enf",
  "hooks": { ... }
}
```

**권장**: hooks가 많아질 경우 `hooks/hooks.json` 분리 방식 사용

### Hook 타입

| 타입 | 설명 |
|------|------|
| `PostToolUse` | 도구 사용 후 실행 |

### Matcher 패턴

| 패턴 | 매칭 대상 |
|------|----------|
| `Write` | 파일 생성 |
| `Edit` | 파일 수정 |
| `Write\|Edit` | 파일 생성 또는 수정 |

### 스크립트 작성

`scripts/my-check.sh`:

```bash
#!/bin/bash
# 파일 경로를 인자로 받음
FILE="$1"

# 특정 파일 패턴만 처리
if [[ "$FILE" =~ \\.tsx?$ ]]; then
  # 검사 로직
  if grep -q "console.log" "$FILE"; then
    echo "경고: console.log가 포함되어 있습니다."
  fi
fi

# 종료 코드
# 0: 성공 (계속 진행)
# 1: 경고 (메시지 표시 후 진행)
# 2+: 오류 (작업 중단)
exit 0
```

실행 권한 부여:

```bash
chmod +x scripts/my-check.sh
```

### Hook 동작 흐름

```
┌─────────────────────────────────────────────────────┐
│              Claude Code 파일 수정                    │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│         PostToolUse Hook 트리거 (Write|Edit)          │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│            post-write-check.sh (통합 스크립트)         │
│                                                     │
│  .env* → 경고 (exit 1)                               │
│  .ts/.tsx 아닌 파일 → 즉시 종료 (exit 0)               │
│  schema.prisma → Prisma 안내                         │
│  .ts/.tsx → TypeScript 안내                           │
│  _actions/*.ts → Server Action 추가 검사              │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│              Claude에게 결과 피드백                    │
└─────────────────────────────────────────────────────┘
```

---

## 환경 변수

### Hook 스크립트에서 사용 가능

| 변수 | 설명 | 예시 |
|------|------|------|
| `$TOOL_INPUT_file_path` | 수정된 파일 경로 | `/src/app/page.tsx` |
| `$TOOL_INPUT_content` | Write 도구의 파일 내용 | - |
| `$TOOL_INPUT_old_string` | Edit 도구의 교체 대상 | - |
| `$TOOL_INPUT_new_string` | Edit 도구의 새 문자열 | - |
| `$CLAUDE_PLUGIN_ROOT` | 플러그인 루트 경로 | `/path/to/plugin` |

### 스크립트 활용 예시

```bash
#!/bin/bash

FILE="$TOOL_INPUT_file_path"
PLUGIN_DIR="$CLAUDE_PLUGIN_ROOT"

# 플러그인 설정 파일 읽기
CONFIG="$PLUGIN_DIR/.claude-plugin/plugin.json"

# 파일 확장자 추출
EXT="${FILE##*.}"

# 디렉토리 추출
DIR=$(dirname "$FILE")
```

---

## 검증 및 테스트

### 플러그인 검증

```bash
# 매니페스트 유효성 검사
claude plugin validate ~/plugins/enf

# 상세 검증 (디버그 모드)
claude plugin validate ~/plugins/enf --verbose
```

### 로컬 테스트

```bash
# 플러그인 디렉토리에서 Claude 실행
claude --plugin-dir ./etvibe-nextjs-fullstack

# 에이전트 확인
/agents

# 커맨드 테스트
/enf:init
/enf:my-command

# MCP 서버 상태
/mcp
```

### 체크리스트

#### Agent 추가 시

- [ ] `agents/` 디렉토리에 `.md` 파일 생성
- [ ] frontmatter에 name, description 필수
- [ ] 역할과 작업 지침 명확히 작성
- [ ] `/agents`에서 목록 확인

#### Command 추가 시

- [ ] `commands/` 디렉토리에 `.md` 파일 생성
- [ ] 파일명 = 커맨드명 확인
- [ ] 사용법과 예시 포함
- [ ] `/enf:command-name`으로 테스트

#### Skill 추가 시

- [ ] `skills/` 디렉토리에 `.md` 파일 생성
- [ ] triggers 키워드 설정 (자동 활성화용)
- [ ] 코드 패턴 예시 포함
- [ ] 키워드 언급 시 활성화 확인

#### Hook 추가 시

- [ ] `scripts/` 디렉토리에 스크립트 생성
- [ ] 실행 권한 부여 (`chmod +x`)
- [ ] `hooks/hooks.json`에 등록
- [ ] 경로에 `${CLAUDE_PLUGIN_ROOT}` 사용 확인
- [ ] 파일 수정 후 동작 확인

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [GUIDELINES](./GUIDELINES.md) | 플러그인 철학 및 워크플로우 |
| [DEVELOPMENT](./DEVELOPMENT.md) | 로컬 개발 및 디버깅 |
| [CONTRIBUTING](./CONTRIBUTING.md) | 기여 가이드 |
