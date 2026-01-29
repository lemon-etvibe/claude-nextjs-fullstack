---
name: commit
description: Git 커밋 생성 - Conventional Commits 형식
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# /commit 명령어

변경사항을 분석하고 Conventional Commits 형식의 커밋을 생성합니다.

> **참고**: 외부 플러그인 `commit-commands`가 설치된 경우 해당 플러그인이 우선 사용됩니다.
> 이 명령어는 폴백용으로 제공됩니다.

## 사용법

```
/commit                         # 자동 커밋 메시지 생성
/commit "<메시지>"              # 직접 메시지 지정
/commit --amend                 # 이전 커밋 수정
```

## Conventional Commits 형식

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type

| Type | 설명 |
| ---- | ---- |
| `feat` | 새로운 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `style` | 코드 포맷팅 (기능 변경 없음) |
| `refactor` | 코드 리팩토링 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드, 설정 등 기타 |
| `perf` | 성능 개선 |

### Scope (선택적)

변경이 영향을 미치는 영역:

- `auth` - 인증 관련
- `customer` - 고객 관련
- `campaign` - 캠페인 관련
- `ui` - UI 컴포넌트
- `prisma` - 데이터베이스
- `api` - API 관련

### 예시

```
feat(customer): 고객 목록 필터 기능 추가

- 상태별 필터 추가
- 가입일 기준 정렬 추가
- 검색 기능 구현

Closes #123
```

## 워크플로우

### 1. 변경사항 확인

```bash
git status
git diff --staged
git diff
```

### 2. 변경사항 분석

- 어떤 파일이 변경되었는가?
- 어떤 유형의 변경인가? (feat/fix/refactor 등)
- 변경의 범위는? (scope)

### 3. 스테이징

```bash
# 특정 파일
git add src/app/(admin)/_actions/customer.ts

# 관련 파일 모두
git add src/app/(admin)/
```

### 4. 커밋 생성

```bash
git commit -m "feat(customer): 고객 검색 기능 추가"
```

## 커밋 메시지 작성 가이드

### DO

- 현재 시제 사용 ("Add" not "Added")
- 첫 글자 소문자 (영문) 또는 한글
- 50자 이내의 제목
- 무엇을, 왜 변경했는지 설명

### DON'T

- 마침표로 끝내지 않음
- "커밋" 같은 자명한 단어 사용
- 너무 모호한 설명 ("수정", "업데이트")

## 출력 형식

```markdown
## 커밋 생성

### 변경사항 분석
- **변경된 파일**: N개
- **추가**: N줄
- **삭제**: N줄

### 변경 파일 목록
- `src/app/(admin)/_actions/customer.ts` - 고객 검색 액션 추가
- `src/app/(admin)/_components/CustomerSearch.tsx` - 검색 UI 컴포넌트

### 생성된 커밋
```bash
git add src/app/(admin)/_actions/customer.ts src/app/(admin)/_components/CustomerSearch.tsx
git commit -m "feat(customer): 고객 검색 기능 추가"
```

### 결과
- **커밋 해시**: abc1234
- **브랜치**: feat/customer-search
```

## 연계 명령어

- `/task` - 작업 시작
- `/push` - 원격 푸시
- `/pr` - PR 생성
