---
description: 업무 정의 및 Git 브랜치 생성 - 작업 시작 워크플로우
allowed-tools:
  - Bash
  - Read
  - Glob
---

# /task 명령어

새로운 작업을 시작할 때 업무를 정의하고 Git 브랜치를 생성합니다.

## 사용법

```
/task "<작업 설명>"
/task "로그인 페이지 구현"
/task "고객 목록 필터 기능 추가"
/task "버그 수정: 이메일 유효성 검사"
```

## 워크플로우

### 1. 작업 유형 분류

| 접두어 | 유형 | 설명 |
| ------ | ---- | ---- |
| `feat/` | Feature | 새로운 기능 |
| `fix/` | Bug Fix | 버그 수정 |
| `refactor/` | Refactor | 코드 개선 (기능 변경 없음) |
| `docs/` | Documentation | 문서 작성/수정 |
| `style/` | Style | 코드 스타일 변경 |
| `test/` | Test | 테스트 추가/수정 |
| `chore/` | Chore | 빌드, 설정 등 기타 |

### 2. 브랜치명 생성 규칙

```
<type>/<short-description>

예시:
feat/customer-login
fix/email-validation
refactor/campaign-table
docs/api-readme
```

### 3. 실행 단계

1. 현재 브랜치 상태 확인
2. 작업 유형 분류
3. 브랜치명 생성
4. dev 브랜치에서 새 브랜치 생성

```bash
# 현재 상태 확인
git status

# dev 브랜치 확인 (없으면 main에서 생성)
if ! git show-ref --verify --quiet refs/heads/dev; then
  git checkout main
  git pull origin main
  git checkout -b dev
  git push -u origin dev
fi

# dev 최신화
git checkout dev
git pull origin dev

# 새 브랜치 생성
git checkout -b feat/customer-login
```

### 4. 작업 컨텍스트 설정

브랜치 생성 후 다음을 확인/안내합니다:

- 관련 파일 위치 (Route Group, 컴포넌트 등)
- 필요한 데이터 모델
- 참고할 기존 패턴

## 브랜치 명명 규칙

### DO

- 소문자 사용
- 하이픈으로 단어 구분
- 간결하고 명확한 설명
- 영문 사용

### DON'T

- 한글 사용
- 너무 긴 이름 (3-4 단어 이내)
- 특수문자 사용 (하이픈 제외)
- 이슈 번호만 사용

## 출력 형식

```markdown
## 작업 시작: {작업 설명}

### 브랜치 정보
- **유형**: Feature
- **브랜치명**: `feat/customer-login`
- **기반 브랜치**: dev

### 실행된 명령어
```bash
git checkout dev
git pull origin dev
git checkout -b feat/customer-login
```

### 작업 컨텍스트
- **Route Group**: (admin)/admin/(protected)/
- **관련 파일**:
  - `src/app/(admin)/_actions/auth.ts`
  - `src/app/(admin)/_components/LoginForm.tsx`

### 다음 단계
1. 기능 구현
2. `/commit` - 변경사항 커밋
3. `/push` - 원격 푸시
4. `/pr` - PR 생성 (→ dev 브랜치로 머지)
```

## 연계 명령어

- `/design-feature` - 기능 설계 (복잡한 작업 시)
- `/commit` - 변경사항 커밋
- `/push` - 원격 푸시
- `/pr` - PR 생성
