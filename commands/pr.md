---
name: pr
description: GitHub Pull Request 생성 - 자동 템플릿 적용
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# /pr 명령어

현재 브랜치로 GitHub Pull Request를 생성합니다.

## 사용법

```
/pr                             # 자동 PR 생성
/pr --draft                     # Draft PR 생성
/pr --base develop              # 타겟 브랜치 지정
```

## 워크플로우

### 1. 사전 체크

```bash
# 현재 브랜치 확인
git branch --show-current

# 원격에 푸시되었는지 확인
git log origin/$(git branch --show-current)..HEAD --oneline

# 이미 PR이 있는지 확인
gh pr list --head $(git branch --show-current)
```

### 2. 변경사항 분석

```bash
# main과의 차이 확인
git log main..HEAD --oneline

# 변경된 파일 목록
git diff main...HEAD --stat
```

### 3. PR 생성

```bash
gh pr create \
  --title "feat(customer): 고객 로그인 기능 구현" \
  --body "$(cat <<'EOF'
## 개요

고객 로그인 페이지 및 인증 기능을 구현했습니다.

## 변경사항

- 로그인 폼 UI 구현
- Better Auth 연동
- 세션 관리 설정

## 테스트

- [ ] 로그인 성공 테스트
- [ ] 잘못된 비밀번호 테스트
- [ ] 세션 만료 테스트

## 스크린샷

(해당 시 첨부)

## 체크리스트

- [ ] 코드 리뷰 준비 완료
- [ ] 테스트 통과
- [ ] 문서 업데이트 (필요 시)
EOF
)"
```

## PR 템플릿

```markdown
## 개요

{변경사항 요약 - 1-2문장}

## 변경사항

- {주요 변경 1}
- {주요 변경 2}
- {주요 변경 3}

## 관련 이슈

- Closes #{이슈 번호}

## 테스트

- [ ] {테스트 항목 1}
- [ ] {테스트 항목 2}

## 스크린샷

{UI 변경 시 스크린샷 첨부}

## 체크리스트

- [ ] 코드 리뷰 준비 완료
- [ ] 테스트 통과
- [ ] TypeScript 에러 없음
- [ ] lint 에러 없음
```

## PR 제목 규칙

Conventional Commits 형식을 따릅니다:

```
<type>(<scope>): <description>

예시:
feat(customer): 고객 로그인 기능 구현
fix(auth): 세션 만료 처리 수정
refactor(campaign): 캠페인 테이블 컴포넌트 분리
```

## 자동 분석 내용

PR 생성 시 다음을 자동으로 분석합니다:

1. **커밋 메시지 분석** - PR 제목과 본문 초안 생성
2. **변경 파일 분석** - 변경사항 요약
3. **영향 범위 파악** - 관련 기능 영역 식별

## 출력 형식

```markdown
## PR 생성 결과

### PR 정보
- **제목**: feat(customer): 고객 로그인 기능 구현
- **브랜치**: feat/customer-login → main
- **URL**: https://github.com/user/repo/pull/123

### 포함된 커밋
- abc1234 feat(customer): 로그인 폼 구현
- def5678 feat(customer): 로그인 API 연동

### 변경된 파일 (5개)
- `src/app/(site)/(auth)/login/page.tsx`
- `src/app/(site)/_actions/auth.ts`
- `src/app/(site)/_components/LoginForm.tsx`
- `src/app/(site)/_lib/schemas.ts`
- `src/lib/auth.ts`

### 다음 단계
1. PR 리뷰 요청
2. CI 통과 확인
3. 리뷰 피드백 반영
4. 머지
```

## 연계 명령어

- `/commit` - 커밋 생성
- `/push` - 원격 푸시
- `/code-review` - 코드 리뷰 (PR 전 자체 점검)

## 외부 플러그인 연계

PR 리뷰는 `pr-review-toolkit` 플러그인에 위임합니다:
- `/review-pr` - PR 리뷰 수행
