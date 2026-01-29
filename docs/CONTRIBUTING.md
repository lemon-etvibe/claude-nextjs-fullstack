# 기여 가이드

이 문서는 `etvibe-nextjs-fullstack` 플러그인에 기여하는 방법을 안내합니다.

## 목차

- [브랜치 규칙](#브랜치-규칙)
- [PR 프로세스](#pr-프로세스)
- [코드 리뷰 체크리스트](#코드-리뷰-체크리스트)
- [커밋 메시지 규칙](#커밋-메시지-규칙)

---

## 브랜치 규칙

### 브랜치 구조

| 브랜치 | 용도 | 직접 푸시 |
|--------|------|:--------:|
| `main` | 프로덕션/릴리스 | ❌ |
| `dev` | 개발/테스트 | ✅ |
| `feature/*` | 기능 개발 | ✅ |
| `fix/*` | 버그 수정 | ✅ |
| `docs/*` | 문서 업데이트 | ✅ |

### main 브랜치 보호

`main` 브랜치는 다음 규칙이 적용됩니다:

- ❌ **직접 커밋 금지** - 모든 변경은 PR을 통해서만 가능
- ✅ **PR 필수** - Pull Request 생성 필요
- ✅ **승인 필수** - 최소 1명의 CODEOWNERS 승인 필요
- ✅ **최신 승인 필수** - 새 커밋 시 기존 승인 무효화

### 워크플로우

```
1. feature/* 또는 fix/* 브랜치 생성
2. 작업 후 dev로 푸시 또는 PR
3. dev에서 테스트
4. dev → main PR 생성
5. CODEOWNERS 승인
6. main으로 머지
```

---

## PR 프로세스

### Step 1: 브랜치 생성

```bash
# 기능 개발
git checkout -b feature/add-new-command

# 버그 수정
git checkout -b fix/hook-error

# 문서 업데이트
git checkout -b docs/update-readme
```

### Step 2: 작업 및 커밋

```bash
# 변경사항 확인
git status
git diff

# 커밋
git add <files>
git commit -m "feat: add new command for ..."
```

### Step 3: PR 생성

```bash
# dev 브랜치로 PR (일반 작업)
gh pr create \
  --base dev \
  --title "feat: add new command" \
  --body "## Summary
- 새 명령어 추가
- 관련 문서 업데이트
"

# main 브랜치로 PR (릴리스)
gh pr create \
  --base main \
  --head dev \
  --title "Release v1.2.3" \
  --body "## Changes
- 변경사항 목록
"
```

### Step 4: 코드 리뷰

- CODEOWNERS가 자동으로 리뷰어로 지정됨
- 피드백 반영 후 다시 커밋
- 새 커밋 시 재승인 필요

### Step 5: 머지

- 모든 승인 완료 후 머지
- Squash and Merge 권장

---

## 코드 리뷰 체크리스트

### 일반

- [ ] 코드가 목적에 맞게 동작하는가?
- [ ] 불필요한 변경사항이 없는가?
- [ ] 하위 호환성이 유지되는가?

### Commands

- [ ] frontmatter (`name`, `description`) 올바른가?
- [ ] 네임스페이스 규칙 (`/enf:`) 준수하는가?
- [ ] 실행 절차가 명확한가?

### Agents

- [ ] 역할이 명확하게 정의되었는가?
- [ ] MCP 서버 설정이 올바른가?
- [ ] 기존 에이전트와 역할이 중복되지 않는가?

### Hooks/Scripts

- [ ] 스크립트에 실행 권한(`chmod +x`)이 있는가?
- [ ] 에러 처리가 적절한가?
- [ ] 파일 경로 패턴 매칭이 정확한가?
- [ ] shellcheck 경고가 없는가?

### Skills

- [ ] triggers 키워드가 적절한가?
- [ ] 코드 예시가 정확한가?
- [ ] 최신 버전 정보가 반영되었는가?

### 문서

- [ ] 문서가 정확하고 최신 상태인가?
- [ ] 링크가 정상 동작하는가?
- [ ] 코드 예시가 동작하는가?

---

## 커밋 메시지 규칙

### Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

| Type | 설명 |
|------|------|
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `style` | 포맷팅, 세미콜론 등 |
| `refactor` | 코드 리팩토링 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드, 설정 변경 |

### Scope (선택)

| Scope | 설명 |
|-------|------|
| `commands` | 슬래시 명령어 |
| `agents` | 에이전트 |
| `hooks` | 훅/스크립트 |
| `skills` | 스킬 |
| `docs` | 문서 |

### 예시

```bash
# 좋은 예
feat(commands): add waterfall-check command
fix(hooks): resolve script path issue on Windows
docs: update README installation guide
chore: bump version to 1.2.3

# 나쁜 예
update code          # type 없음
feat: stuff          # 설명 부족
FEAT: Add Feature    # 대문자 사용
```

### Subject 규칙

- 첫 글자 소문자
- 마침표 없음
- 명령형 사용 ("add" not "added")
- 50자 이내

---

## 이슈 보고

### 버그 리포트

```markdown
## 버그 설명
[버그에 대한 명확한 설명]

## 재현 절차
1. [첫 번째 단계]
2. [두 번째 단계]
3. [에러 발생]

## 예상 동작
[어떻게 동작해야 하는지]

## 실제 동작
[실제로 어떻게 동작했는지]

## 환경
- OS: [예: macOS 14.0]
- Claude Code 버전: [예: 1.0.0]
- 플러그인 버전: [예: 1.2.3]
```

### 기능 요청

```markdown
## 기능 설명
[요청하는 기능에 대한 설명]

## 동기
[이 기능이 필요한 이유]

## 제안하는 해결책
[구현 방법 제안 (선택)]

## 대안
[고려한 다른 방법들 (선택)]
```

---

## 질문 및 도움

- **GitHub Issues**: 버그 리포트, 기능 요청
- **GitHub Discussions**: 질문, 아이디어 공유

---

## 다음 단계

- [커스터마이징 가이드](./CUSTOMIZATION.md) - Hooks, Commands, Agents 확장
- [개발 가이드](./DEVELOPMENT.md) - 로컬 테스트 및 디버깅
