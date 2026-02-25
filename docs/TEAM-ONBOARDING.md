# 팀 온보딩 가이드

신규 팀원을 위한 etvibe-nextjs-fullstack (enf) 플러그인 빠른 시작 가이드입니다.

---

## 목차

- [개요](#개요)
- [Step 1: 플러그인 설치](#step-1-플러그인-설치)
- [Step 2: 핵심 개념 이해](#step-2-핵심-개념-이해)
- [Step 3: 첫 작업 실습](#step-3-첫-작업-실습)
- [Step 4: 다음 단계](#step-4-다음-단계)
- [온보딩 체크리스트](#온보딩-체크리스트)

---

## 개요

### 이 플러그인이란?

**enf** (etvibe-nextjs-fullstack)는 Next.js 16 + Prisma 7 + Better Auth 풀스택 개발을 위한 Claude Code 플러그인입니다.

### 제공 기능

| 기능 | 설명 |
|------|------|
| **Agents** | 전문 역할별 AI 에이전트 (4개) |
| **Commands** | 개발 워크플로우 자동화 (15개) |
| **Skills** | 기술별 지식 베이스 (4개) |
| **MCP Servers** | 외부 도구 연동 (3개) |
| **Hooks** | 자동 검증 (3개) |

---

## Step 1: 플러그인 설치

> **상세 설치 가이드**: [INSTALLATION.md](./INSTALLATION.md)

```bash
# 마켓플레이스 등록 및 설치
claude plugin marketplace add https://github.com/lemon-etvibe/etvibe-nextjs-fullstack
claude plugin install enf@enf
```

설치 완료 후 확인:

```bash
cd ~/projects/your-project && claude
> /agents    # 에이전트 4개 확인
> /enf:init  # 가이드 확인
```

---

## Step 2: 핵심 개념 이해

### 네임스페이스 규칙

모든 enf 플러그인 명령어는 `/enf:` 접두사를 사용합니다.

```bash
# enf 플러그인 명령어
/enf:code-review
/enf:commit
/enf:task

# 다른 플러그인 명령어 (참고)
/commit-commands:commit
/review-pr
```

### Agent 역할

| Agent | 언제 사용? | Write/Edit |
|-------|-----------|:----------:|
| `dev-assistant` | 코드 구현, 리뷰, 리팩토링 | O |
| `architecture-expert` | 새 기능/페이지 설계 | X |
| `performance-expert` | 성능 문제 분석 | O |
| `docs-writer` | 문서 작성 | O |

### TOP 5 명령어

| 명령어 | 용도 | 사용 시점 |
|--------|------|----------|
| `/enf:task` | 브랜치 생성 | 작업 시작 시 |
| `/enf:code-review` | 코드 리뷰 | 구현 완료 후 |
| `/enf:commit` | 커밋 생성 | 변경사항 저장 시 |
| `/enf:push` | 안전한 푸시 | 원격 저장소 업로드 시 |
| `/enf:pr` | PR 생성 | 코드 리뷰 요청 시 |

### 프로젝트 구조 (Co-location)

```
src/app/
├── (admin)/              # 관리자 영역
│   ├── _actions/         # Server Actions
│   ├── _components/      # 전용 컴포넌트
│   ├── _lib/             # 훅/스키마
│   └── admin/            # 라우트
│
├── (site)/               # 고객 영역
│   ├── _actions/
│   ├── _components/
│   ├── _lib/
│   └── (main)/, (auth)/, (customer)/
│
└── api/                  # API Routes
```

> `_` prefix 폴더는 라우팅에서 제외됩니다 (Private Folders)

---

## Step 3: 첫 작업 실습

### 실습 1: 간단한 기능 수정

```bash
# 1. Claude 실행
cd ~/projects/your-project
claude

# 2. 작업 브랜치 생성
> /enf:task "버튼 색상 변경"

# 3. 파일 수정 요청
> src/components/ui/button.tsx의 primary 색상을 파란색으로 변경해줘

# 4. 코드 리뷰
> /enf:code-review src/components/ui/button.tsx

# 5. 커밋
> /enf:commit
```

### 실습 2: Server Action 작성

```bash
# 1. 새 기능 요청
> 고객 정보를 업데이트하는 Server Action을 작성해줘

# 2. 코드 리뷰 (자동으로 인증 패턴 확인)
> /enf:code-review src/app/(admin)/_actions/customer.ts

# 3. 커밋 및 푸시
> /enf:commit
> /enf:push
```

### 실습 3: PR 생성

```bash
# 1. PR 생성
> /enf:pr

# 2. (자동으로 생성되는 내용)
# - 제목: 브랜치명 기반
# - 본문: 커밋 내용 요약
# - 라벨: 자동 추가
```

---

## Step 4: 다음 단계

### 필수 읽기 자료

| 순서 | 문서 | 내용 |
|:----:|------|------|
| 1 | [GUIDELINES](./GUIDELINES.md) | 플러그인 철학, 역할 정의 |
| 2 | [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 상세 사용법 |
| 3 | [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 상황별 워크플로우 |

### 유용한 명령어

```bash
# 설계가 필요한 기능
> /enf:design-feature "복잡한 기능 설명"

# 성능 분석
> /enf:perf-audit

# Prisma 스키마 리뷰
> /enf:schema-design

# 리팩토링 제안
> /enf:refactor src/path/to/file.ts

# Waterfall 패턴 검출
> /enf:waterfall-check src/app/
```

### 스킬 활용

특정 키워드를 언급하면 관련 스킬이 자동으로 활성화됩니다.

```bash
# Better Auth 관련 작업
> 로그인 기능을 구현해줘
# → better-auth 스킬 자동 활성화

# Prisma 관련 작업
> 캠페인 스키마를 설계해줘
# → prisma-7 스킬 자동 활성화

# UI 관련 작업
> shadcn 폼 컴포넌트를 만들어줘
# → tailwind-v4-shadcn 스킬 자동 활성화
```

---

## 온보딩 체크리스트

### 설치 확인

- [ ] 플러그인 설치 완료 (`claude plugin list`에서 enf 확인)
- [ ] `/agents` 명령어로 4개 에이전트 확인
- [ ] `/mcp` 명령어로 MCP 서버 상태 확인
- [ ] `/enf:init` 실행 및 가이드 확인
- [ ] `/enf:health` 실행하여 프로젝트 호환성 확인

### 첫 작업 완료

- [ ] `/enf:task`로 브랜치 생성
- [ ] 간단한 코드 수정
- [ ] `/enf:code-review` 실행
- [ ] `/enf:commit`으로 커밋 생성

### 문서 학습

- [ ] [GUIDELINES.md](./GUIDELINES.md) 읽기
- [ ] [AGENTS-MANUAL.md](./AGENTS-MANUAL.md) 읽기
- [ ] [SCENARIO-GUIDES.md](./SCENARIO-GUIDES.md) 읽기

### 심화 학습 (선택)

- [ ] [SKILLS-ACTIVATION.md](./SKILLS-ACTIVATION.md) - 스킬 상세
- [ ] [CUSTOMIZATION.md](./CUSTOMIZATION.md) - 확장 방법
- [ ] [CONTRIBUTING.md](./CONTRIBUTING.md) - 기여 방법

---

## 자주 묻는 질문

### Q: 명령어가 동작하지 않아요

```bash
# 플러그인 재설치
claude plugin install enf@enf

# Claude 재시작
claude
```

### Q: 에이전트가 보이지 않아요

```bash
# 에이전트 목록 확인
/agents

# enf 플러그인 설치 확인
claude plugin list
```

### Q: MCP 서버 연결 실패

```bash
# MCP 상태 확인
/mcp

# 개발 서버가 실행 중인지 확인 (next-devtools)
pnpm dev
```

### Q: 어떤 Agent를 사용해야 할지 모르겠어요

```
설계 → architecture-expert
구현 → dev-assistant
성능 → performance-expert
문서 → docs-writer
```

---

## 도움 요청

- GitHub Issues: https://github.com/lemon-etvibe/etvibe-nextjs-fullstack/issues

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [README](../README.md) | 프로젝트 개요 |
| [GUIDELINES](./GUIDELINES.md) | 플러그인 철학 |
| [AGENTS-MANUAL](./AGENTS-MANUAL.md) | 에이전트 매뉴얼 |
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md) | 시나리오별 가이드 |
| [INSTALLATION](./INSTALLATION.md) | 상세 설치 가이드 |
