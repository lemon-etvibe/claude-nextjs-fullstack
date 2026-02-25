# 팀 온보딩 가이드

etvibe-nextjs-fullstack (enf) 플러그인을 처음 사용하는 팀원을 위한 빠른 시작 가이드입니다.

---

## 사전 요구사항

- **Claude Code** CLI 설치 완료 ([공식 문서](https://docs.anthropic.com/en/docs/claude-code))
- **Node.js** 20.x 이상
- **Git** 설치

---

## 1단계: 플러그인 설치

```bash
# 마켓플레이스 등록 (최초 1회)
claude plugin marketplace add https://github.com/lemon-etvibe/claude-nextjs-fullstack

# 플러그인 설치
claude plugin install enf@enf
```

설치 확인:

```bash
claude plugin list    # enf 플러그인 확인
```

---

## 2단계: 프로젝트에서 사용

```bash
cd ~/projects/my-app
claude
```

Claude Code 실행 후 확인:

```bash
/agents      # 에이전트 4개 확인
/enf:init    # 플러그인 사용법 안내
```

---

## 3단계: 기본 워크플로우

```
/enf:task "기능명"          →  브랜치 자동 생성
       ↓
/enf:design-feature         →  아키텍처 설계 (선택)
       ↓
    [구현]                   →  dev-assistant 활용
       ↓
/enf:code-review            →  품질 검사
       ↓
/enf:commit → /enf:push → /enf:pr
```

---

## 자주 쓰는 명령어

| 명령어 | 설명 |
|--------|------|
| `/enf:init` | 플러그인 가이드 |
| `/enf:task "기능명"` | 작업 브랜치 생성 |
| `/enf:code-review` | 코드 리뷰 |
| `/enf:commit` | 컨벤션 커밋 |
| `/enf:push` | 안전 체크 후 푸시 |
| `/enf:pr` | PR 생성 |
| `/enf:health` | 프로젝트 호환성 검사 |

---

## 에이전트 활용

Claude Code에서 에이전트를 호출하면 역할별 전문 지원을 받을 수 있습니다.

| 에이전트 | 호출 시점 |
|----------|----------|
| **dev-assistant** | 코드 구현, 리팩토링, 리뷰 |
| **architecture-expert** | 새 기능 설계, 데이터 모델링 |
| **performance-expert** | 성능 분석, 번들 최적화 |
| **docs-writer** | API/컴포넌트 문서 자동 생성 |

---

## 업데이트

```bash
claude plugin update enf@enf
```

---

## 문제 해결

- 플러그인이 안 보일 때: `claude plugin list`로 설치 상태 확인
- 에이전트가 안 뜰 때: `/agents`로 확인, 안 되면 `claude plugin install enf@enf` 재설치
- 상세 문제 해결: [INSTALLATION.md](./INSTALLATION.md) 참고

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [README](../README.md) | 전체 개요 |
| [Commands Reference](./COMMANDS-REFERENCE.md) | 전체 명령어 목록 |
| [Installation](./INSTALLATION.md) | 상세 설치 가이드 |
| [Scenario Guides](./SCENARIO-GUIDES.md) | 상황별 워크플로우 |
